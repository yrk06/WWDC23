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
    
    var onStartButtonPressed : (()->Void)!
    var isStarted = false
    
    static func createHUD(reset: (()->Void)!, onStart: (()->Void)!) -> BoardHud {
        // Doesnt work in an actual playground, god why???
        // let hud = SKScene(fileNamed: "HUD") as! BoardHud
        let hud = BoardHud(fileNamed: "HUD")!
        hud.onStartButtonPressed = onStart
        
        hud.scaleMode = .aspectFit
        hud.isUserInteractionEnabled = false
        hud.isPaused = false
        hud.reset = reset
        
        let blur = SKEffectNode()
        let backdrop = hud.childNode(withName: "//backdrop")!
        backdrop.addChild(blur)
        blur.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 75])
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
            
            let showUp = SKAction.moveBy(x: -384, y: 0, duration: 0.5)
            showUp.timingMode = .easeOut
            board.position.x = 192
            board.run(showUp)
            let realIndex = index > 4 ? 5 : index
            board.position.y = CGFloat(-(196/2) - (204 * realIndex))
            
            board.setScale(0.75)
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
                let exit = SKAction.moveTo(x: 512, duration: 0.25)
                exit.timingMode = .easeIn
                await remainingAction.run(exit)
            }
            
            let gameover = childNode(withName: "//Gameover")!
            let gameOverEntry = SKAction.moveTo(x: -192, duration: 0.5)
            gameOverEntry.timingMode = .easeOut
            await gameover.run(gameOverEntry)
        }
        
    }
    
    func consumeAction() async {
        
        let action = listOfActions.remove(at: 0)
        
        let fallOut = SKAction.moveTo(x: 512, duration: 0.2)
        fallOut.timingMode = .easeIn
        
        await action.run(fallOut)
        action.removeFromParent()
        
        let rise = SKAction.move(by: CGVector(dx: 0, dy: 204), duration: 0.1)
        rise.timingMode = .easeInEaseOut
        
        for (index , remainingAction) in listOfActions.enumerated() {
            if index > 4 {
                break
            }
            
            await remainingAction.run(rise)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let restartButton = childNode(withName: "//restart")!
        let startButton = childNode(withName: "//startButton")!

        for touch in touches {
            let location = touch.location(in: self)
            if restartButton.contains(restartButton.parent!.convert(location, from: self)) {
                reset()
            }
            
            if !isStarted && startButton.contains(startButton.parent!.convert(location, from: self)) {
                isStarted = true
                let startNode = childNode(withName: "//Start")
                startNode?.isHidden = true
                onStartButtonPressed()
            }
            
        }
    }
}
