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
    
    static func newGameboard() -> SCNNode {
        
        let node = GameboardNode()
        let url = Bundle.main.url(forResource: "Gameboard", withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        node.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
        
        let ship = node.childNode(withName: "ship_light_wood", recursively: true)
        
        let rockAnimation = CABasicAnimation(keyPath: "transform.euler.z")
        rockAnimation.fromValue = (-7 * Float.pi) / 180
        rockAnimation.toValue = (7 * Float.pi) / 180
        rockAnimation.autoreverses = true
        rockAnimation.repeatCount = .infinity
        rockAnimation.duration = 5
        rockAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        //ship?.addAnimation(floatAnimation, forKey: nil)
        ship?.addAnimation(rockAnimation, forKey: nil)
        
        
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
            BoardElement(boardPosition: SIMD2<Int>(0,6), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
        ]))
        
        node.playerController = PlayerController(at: SIMD2<Int>(0,0))
        
        node.addChildNode(node.playerController!)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            Task {
                await node.runActionQueue()
            }
            
        }
        
        
        
        return node
    }
    
    var playerActionIndex = 0
    var playerActionQueue = [
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
        PlayerAction(distance: 8, rotate: 0),
        PlayerAction(distance: 0, rotate: -1),
        
//        PlayerAction(distance: 2, rotate: 0),
//        PlayerAction(distance: 0, rotate: 1),
//        PlayerAction(distance: 2, rotate: 0),
//        PlayerAction(distance: 0, rotate: -1),
//
//        PlayerAction(distance: 6, rotate: 0),
//        PlayerAction(distance: 0, rotate: -1),
    
    ]
    func runNextPlayerAction() async {
        let action = playerActionQueue[playerActionIndex]
        
        await playerController!.updateRotation(rotation: action.rotate)
        
        for _ in 0..<action.distance {
            let nextPos = playerController!.getForwardPosition(tiles: 1)
            let nextTileNum = SzudzikMap(a: nextPos.x, b: nextPos.y)
            
            if level!.collisionTiles.binarySearch(predicate: { tile in
                tile == nextTileNum
            })   {
                gameover = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.playerController?.removeAllActions()
                    
                    let fall = SCNAction.rotateBy(x: 0, y: 0, z: -4 * .pi / 6, duration: 3)
                    fall.timingMode = .easeInEaseOut
                    
                    let rise = SCNAction.rotateBy(x: 0, y: 0, z: .pi / 6, duration: 2)
                    rise.timingMode = .easeInEaseOut
                    
                    let itSink = SCNAction.moveBy(x: 0, y: -0.01, z: 0, duration: 1)
                    
                    self.playerController?.runAction(SCNAction.sequence([
                        fall,rise,itSink
                    ]))
                    
                    self.gameover = true
                    //self.playerController?.removeFromParentNode()
                }
            }
            
            await playerController!.updatePosition(tiles: 1)
        }
        
        playerActionIndex = (playerActionIndex + 1) % playerActionQueue.count
        
        
    }
    
    func runActionQueue() async {
        while true {
            if gameover {
                continue
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
    }
    
}
