//
//  File.swift
//  
//
//  Created by Yerik Koslowski on 05/04/23.
//
import SpriteKit

class BoardHud: SKScene {
    

    var listOfActions : [SKNode] = []
    var reset : (()->Void)!
    
    static func createHUD(reset: (()->Void)!) -> BoardHud {
        let hud = SKScene(fileNamed: "HUD") as! BoardHud
        hud.scaleMode = .aspectFit
        hud.isUserInteractionEnabled = false
        hud.isPaused = false
        hud.reset = reset
        //hud.addChild(actualHud)
        
        return hud
    }
    
    override func didMove(to view: SKView) {
        print("HUD added")
    }
    
    func createListOfActions(list : [PlayerAction]) {
        let anchor = self.childNode(withName: "//NextMovement")
        
        for (index, action) in list.enumerated() {
            let board = SKSpriteNode(imageNamed: "sign")
            board.size.height = 196
            
            let label = SKLabelNode()
                if action.rotate != 0 {
                    label.text = "\(index+1). Rotate \(action.rotate > 0 ? "right": "left") \(abs(action.rotate) == 1 ? "once" : "\(abs(action.rotate)) times")"
                } else {
                    label.text = "\(index+1). Forward \(abs(action.distance) == 1 ? "once" : "\(abs(action.distance)) times")"
                }
                label.fontName = "Treasure Map Deadhand"
                label.fontSize = 64
                label.horizontalAlignmentMode = .center
                label.verticalAlignmentMode = .center
                label.fontColor = UIColor.black
                board.addChild(label)
            
            board.position.x = 256
            board.run(SKAction.moveBy(x: -512, y: 0, duration: 0.5))
            let realIndex = index > 4 ? 5 : index
            board.position.y = CGFloat(-(196/2) - (204 * realIndex))
            anchor?.addChild(board)
            listOfActions.append(board)
        }
    }
    
    func setActionFailure() {
        self.isUserInteractionEnabled = true
        let label = listOfActions[0].children[0] as! SKLabelNode
        label.fontColor = UIColor.red
        
        Task {
            for (index , remainingAction) in listOfActions.enumerated() {
                if index == 0 {
                    continue
                }
                if index > 4 {
                    break
                }
                await remainingAction.run(SKAction.moveTo(x: 512, duration: 0.25))
            }
            
            let gameover = childNode(withName: "//Gameover")!
            await gameover.run(SKAction.moveTo(x: -256, duration: 0.5))
        }
        
    }
    
    func consumeAction() async {
        
        let action = listOfActions.remove(at: 0)
        
        await action.run(SKAction.moveTo(x: 512, duration: 0.2))
            action.removeFromParent()
            for (index , remainingAction) in listOfActions.enumerated() {
                if index > 4 {
                    break
                }
                await remainingAction.run(SKAction.move(by: CGVector(dx: 0, dy: 204), duration: 0.1))
            }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let restartButton = childNode(withName: "//restart")!
        for touch in touches {
            let location = touch.location(in: self)
            if restartButton.contains(restartButton.parent!.convert(location, from: self)) {
                reset()
            }
        }
    }
}
