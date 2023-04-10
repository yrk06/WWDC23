//
//  Gameboard.swift
//  ARobot's Journey
//
//  Created by Yerik Koslowski on 01/04/23.
//
import SceneKit

class GameboardNode : SCNNode {
    
    var level : GameLevel? = nil
    var playerController : PlayerController? = nil
    var gameover = false
    var hud : BoardHud!
    
    static func newGameboard(hud: BoardHud) -> GameboardNode {
        
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
        // Create Grid
        for y in 0..<9 {
            for x in 0..<9 {
                if x == 0 && y == 0 {
                    continue;
                }
                let xcoord = -0.08 + 0.02 * Float(x)
                let zcoord = -0.08 + 0.02 * Float(y)
                let clone = gridPieceNode.clone()
                gridBase.addChildNode(clone)
                clone.position.x = xcoord
                clone.position.z = zcoord
            }
        }
        
        node.loadLevel(level: GameLevel(elements: [
            BoardElement(boardPosition: SIMD2<Int>(6,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(6,6), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,7), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
        ],objective: BoardElement(boardPosition: SIMD2<Int>(8,8), boardSize: SIMD2<Int>(1,1), meshName: "chest")))
        
        node.playerController = PlayerController(at: SIMD2<Int>(0,0))
        
        node.addChildNode(node.playerController!)
        
        
        
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
        hud.createListOfActions(list: playerActionQueue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            Task {
                await self.runActionQueue()
            }
        }
    }
    
    func runNextPlayerAction() async {
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
                    
                    self.hud.setActionFailure()
                    self.gameover = true
                    //self.playerController?.removeFromParentNode()
                }
            }
            
            if nextPos == level?.objective.boardPosition {
                print("I have achieved the objective")
                gameover = true
            }
            
            await playerController!.updatePosition(tiles: 1,isFirst: p == 0, isLast: p == (action.distance - 1) )
        }
        
        await hud.consumeAction()
        playerActionIndex += 1
        gameover = gameover ? gameover : playerActionIndex == playerActionQueue.count
        
        
    }
    
    func runActionQueue() async {
        while true {
            if gameover {
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
            
            let finalPosition = board2scene(from: obstacle.boardPosition)
            
            referenceNode.position.x = finalPosition.x
            referenceNode.position.y = 0.009
            referenceNode.position.z = finalPosition.z
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
        
    }
    
}
