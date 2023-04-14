//
//  Gameboard.swift
//  ARobot's Journey
//
//  Created by Yerik Koslowski on 01/04/23.
//
import SceneKit
import SwiftUI

class GameboardNode : SCNNode {
    
    var level : GameLevel? = nil
    var playerController : PlayerController? = nil
    var gameover = false
    var playerWon = false
    var hud : BoardHud? = nil
    
    static func newGameboard(hud: BoardHud?, level: GameLevel, instructions : [PlayerAction]) -> GameboardNode {
        
        let node = GameboardNode()
        node.hud = hud
        
        //Create the game board
        let url = Bundle.main.url(forResource: "Gameboard", withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        node.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
        
        // Create the 3D grid
        let gridBase = node.childNode(withName: "grid", recursively: true)!
        //Create X lines
        for x in 1..<9 {
            for z in 1..<36 {
                let xcoord = -0.09 + 0.02 * Float(x)
                let zcoord = -0.09 + 0.005 * Float(z)
                
                let circle = SCNNode(geometry: SCNSphere(radius: 0.0005))
                circle.geometry?.firstMaterial?.diffuse.contents = Color.black
                gridBase.addChildNode(circle)
                circle.position.x = xcoord
                circle.position.z = zcoord
                circle.position.y = 0.01
            }
        }
        // Create Z lines
        for z in 1..<9 {
            for x in 1..<36 {
                let xcoord = -0.09 + 0.005 * Float(x)
                let zcoord = -0.09 + 0.02 * Float(z)
                
                let circle = SCNNode(geometry: SCNSphere(radius: 0.0005))
                circle.geometry?.firstMaterial?.diffuse.contents = Color.black
                gridBase.addChildNode(circle)
                circle.position.x = xcoord
                circle.position.z = zcoord
                circle.position.y = 0.01
            }
        }
        
        node.loadLevel(level: level)
        node.playerActionQueue = instructions
        
        
        //Animation
        node.scale = SCNVector3(0, 0, 0)
        let scaleUp = SCNAction.scale(to: 1, duration: 1)
        scaleUp.timingMode = .easeInEaseOut
        node.runAction(scaleUp)
        
        return node
    }
    
    var playerActionIndex = 0
    var playerActionQueue: [PlayerAction] = []
    
    // start the instruction execution
    func runGame() {
        hud?.createListOfActions(list: playerActionQueue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            Task {
                await self.runActionQueue()
            }
        }
    }
    
    // Execute the action
    func runNextPlayerAction() async {
        if playerActionQueue.count == 0 {
            gameover = true
            return
        }
        let action = playerActionQueue[playerActionIndex]
        
        await playerController!.updateRotation(rotation: action.rotate)
        
        for p in 0..<action.distance {
            let nextPos = playerController!.getForwardPosition(tiles: 1)
            let nextTileNum = SzudzikMap(a: nextPos.x, b: nextPos.y)
            
            if nextPos.x < 0 || nextPos.y < 0 || nextPos.x > 8 || nextPos.y > 8 || level!.collisionTiles.contains(where: {
                $0 == nextTileNum
            })    {
                gameover = true
                
            
                Task {
                    await playerController!.updatePosition(tiles: 1,isFirst: p == 0, isLast: p == (action.distance - 1) || self.gameover || self.playerWon )
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let player = self.playerController!
                    player.removeAllActions()
                    
                    let playerAxis = player.getPlayerRightVector()
                    
                    let fall = SCNAction.rotate(by: .pi / 2, around: playerAxis, duration: 3)
                    let rise = SCNAction.rotate(by: -.pi / 6, around: playerAxis, duration: 2)
                    
                    let itSink = SCNAction.moveBy(x: 0, y: -0.008, z: 0, duration: 3)
                    
                    self.playerController?.runAction(SCNAction.sequence([SCNAction.group([
                    fall,itSink]),rise
                    ]))
                
                }
                
            } else {
                
                await playerController!.updatePosition(tiles: 1,isFirst: p == 0, isLast: p == (action.distance - 1) || self.gameover || self.playerWon )
                
            }
            
            
            
            
            if nextPos == level?.objective.boardPosition {
                playerWon = true
            }
            if self.gameover || self.playerWon {
                break
            }
        }
        
        await hud?.consumeAction()
        playerActionIndex += 1
        
        gameover = gameover ? gameover : (playerActionIndex == playerActionQueue.count && !playerWon)
        
        
    }
    
    // Loop through all the instructions until a gameover of player won
    func runActionQueue() async {
        while true {
            if gameover{
                self.hud?.setActionFailure()
                break
            }
            if playerWon {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.hud?.hideSideBar()
                    self.hud?.showWinPrompt()
                }
                break
            }
            await runNextPlayerAction()
        }
    }
    
    // Load a level and create all its elements and player
    func loadLevel(level: GameLevel) {
        self.level = level
        let obstacleParent = childNode(withName: "obstacles", recursively: true)!
        
        // Create obstacles
        for obstacle in level.elements {
            let url = Bundle.main.url(forResource: obstacle.meshName, withExtension: "scn" )!
            let referenceNode = SCNReferenceNode(url: url)!
            obstacleParent.addChildNode(referenceNode)
            SCNTransaction.begin()
            referenceNode.load()
            SCNTransaction.commit()
            
            var finalPosition = board2scene(from: obstacle.boardPosition)
            
            finalPosition.x += 0.01 * Float(obstacle.boardSize.x - 1)
            finalPosition.z += 0.01 * Float(obstacle.boardSize.y - 1)
            
            referenceNode.position.x = finalPosition.x
            referenceNode.position.y = 0.009
            referenceNode.position.z = finalPosition.z
            
            referenceNode.eulerAngles.y = Float.random(in: 0..<1) * 2 * .pi
        }
        
        //Create objective
        let objective = level.objective
        
        let url = Bundle.main.url(forResource: objective.meshName, withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        obstacleParent.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
        
        let finalPosition = board2scene(from: objective.boardPosition)
        
        referenceNode.position.x = finalPosition.x
        referenceNode.position.y = 0.025
        referenceNode.position.z = finalPosition.z
        
        referenceNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: .pi, z: 0, duration: 5)))
        
        //Create player
        playerController = PlayerController(at: level.playerStart,rotated: level.playerRotation)
        
        addChildNode(playerController!)
    }
    
}
