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
        let url = Bundle.main.url(forResource: "Gameboard", withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        node.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
        
//        let ship = node.childNode(withName: "ship_light_wood", recursively: true)
        
//        let rockAnimation = CABasicAnimation(keyPath: "transform.euler.z")
//        rockAnimation.fromValue = (-7 * Float.pi) / 180
//        rockAnimation.toValue = (7 * Float.pi) / 180
//        rockAnimation.autoreverses = true
//        rockAnimation.repeatCount = .infinity
//        rockAnimation.duration = 5
//        rockAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
//        //ship?.addAnimation(floatAnimation, forKey: nil)
//        ship?.addAnimation(rockAnimation, forKey: nil)
        
        
        let gridPieceNode = node.childNode(withName: "gridPiece", recursively: true)!
        let gridBase = node.childNode(withName: "grid", recursively: true)!
        //Create X lines
        for x in 1..<9 {
            for z in 1..<36 {
                let xcoord = -0.09 + 0.02 * Float(x)
                let zcoord = -0.09 + 0.005 * Float(z)
                
                let circle = SCNNode(geometry: SCNSphere(radius: 0.0005))
                gridBase.addChildNode(circle)
                circle.position.x = xcoord
                circle.position.z = zcoord
                circle.position.y = 0.01
            }
        }
        
        for z in 1..<9 {
            for x in 1..<36 {
                let xcoord = -0.09 + 0.005 * Float(x)
                let zcoord = -0.09 + 0.02 * Float(z)
                
                let circle = SCNNode(geometry: SCNSphere(radius: 0.0005))
                gridBase.addChildNode(circle)
                circle.position.x = xcoord
                circle.position.z = zcoord
                circle.position.y = 0.01
            }
        }
        node.loadLevel(level: level)
        node.playerActionQueue = instructions
//        node.loadLevel(level: GameLevel(elements: [
//            BoardElement(boardPosition: SIMD2<Int>(6,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
//            BoardElement(boardPosition: SIMD2<Int>(4,4), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
//            BoardElement(boardPosition: SIMD2<Int>(1,6), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
//            BoardElement(boardPosition: SIMD2<Int>(1,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
//            BoardElement(boardPosition: SIMD2<Int>(1,3), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
//            BoardElement(boardPosition: SIMD2<Int>(1,0), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
//            BoardElement(boardPosition: SIMD2<Int>(3,8), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
//        ],objective: BoardElement(boardPosition: SIMD2<Int>(8,8), boardSize: SIMD2<Int>(1,1), meshName: "chest")))
        
        
        
        node.scale = SCNVector3(0, 0, 0)
        
        let scaleUp = SCNAction.scale(to: 1, duration: 1)
        scaleUp.timingMode = .easeInEaseOut
        node.runAction(scaleUp)
        
        return node
    }
    
    var playerActionIndex = 0
    var playerActionQueue = [
        
        PlayerAction(distance: 1, rotate: 0),
        PlayerAction(distance: 7, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 2, rotate: 0),
        PlayerAction(distance: 0, rotate: 1),
        PlayerAction(distance: 2, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),

        PlayerAction(distance: 6, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
    
    ]
    
    func runGame() {
        hud?.createListOfActions(list: playerActionQueue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            Task {
                await self.runActionQueue()
            }
        }
    }
    
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let player = self.playerController!
                    player.removeAllActions()
                    
                    let playerAxis = player.getPlayerRightVector()
                    
                    let fall = SCNAction.rotate(by: .pi / 2, around: playerAxis, duration: 3)
                    let rise = SCNAction.rotate(by: -.pi / 6, around: playerAxis, duration: 2)
                    
//                    let fall = SCNAction.rotateBy(x: 0, y: 0, z: -4 * .pi / 6, duration: 3)
//                    fall.timingMode = .easeInEaseOut
//
//                    let rise = SCNAction.rotateBy(x: 0, y: 0, z: .pi / 6, duration: 2)
//                    rise.timingMode = .easeInEaseOut
                    
                    let itSink = SCNAction.moveBy(x: 0, y: -0.008, z: 0, duration: 3)
                    
                    self.playerController?.runAction(SCNAction.sequence([SCNAction.group([
                    fall,itSink]),rise
                    ]))
                    
                    self.gameover = true
                    //self.playerController?.removeFromParentNode()
                
                }
            }
            
            
            
            await playerController!.updatePosition(tiles: 1,isFirst: p == 0, isLast: p == (action.distance - 1) || self.gameover || self.playerWon )
            
            if nextPos == level?.objective.boardPosition {
                playerWon = true
            }
            if self.gameover || self.playerWon {
                break
            }
        }
        
        await hud?.consumeAction()
        playerActionIndex += 1
        gameover = gameover ? gameover : playerActionIndex == playerActionQueue.count && !playerWon
        
        
    }
    
    func runActionQueue() async {
        while true {
            if gameover{
                self.hud?.setActionFailure()
                break
            }
            if playerWon {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.hud?.hideSideBar()
                    self.hud?.showWinBar()
                }
                break
            }
            await runNextPlayerAction()
        }
    }
    
    func loadLevel(level: GameLevel) {
        self.level = level
        let obstacleParent = childNode(withName: "obstacles", recursively: true)!
        // Load Level
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
            
            //referenceNode.scale = SCNVector3(0.001, 0.001, 0.001)
        }
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
        
        
        playerController = PlayerController(at: level.playerStart)
        
        addChildNode(playerController!)
    }
    
}
