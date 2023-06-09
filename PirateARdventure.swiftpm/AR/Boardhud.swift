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
    
    var onWin : (()->Void)! = {}
    var onLose : (()->Void)! = {}
    
    var level = 0
    
    static func createHUD(levelNumber: Int,reset: (()->Void)!, onStart: (()->Void)!, onWin: (()->Void)!, onLose: (()->Void)! ) -> BoardHud {
        // Doesnt work in an actual playground, god why???
        // let hud = SKScene(fileNamed: "HUD") as! BoardHud
        let hud = BoardHud(fileNamed: "HUD")!
        hud.onStartButtonPressed = onStart
        hud.onWin = onWin
        hud.onLose = onLose
        
        hud.level = levelNumber
        
        hud.scaleMode = .aspectFit
        hud.isUserInteractionEnabled = false
        hud.isPaused = false
        hud.reset = reset
        
        let blur = SKEffectNode()
        let backdrop = hud.childNode(withName: "//backdrop")!
        backdrop.addChild(blur)
        blur.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 75])
        //hud.addChild(actualHud)
        let levelLabel = hud.childNode(withName: "//LevelNumber") as? SKLabelNode
        levelLabel?.text = "Level \(levelNumber + 1)"
        
        return hud
    }
    
    override func didMove(to view: SKView) {
        print("HUD added")
    }
    
    // Add the wooden signs for the instructions on the hud
    func createListOfActions(list : [PlayerAction]) {
        let anchor = self.childNode(withName: "//NextMovement")
        
        for (index, action) in list.enumerated() {
            let board = SKSpriteNode(imageNamed: ["sign-gem", "sign-saphire","sign-emerald"][action.getColor()])
            board.size = CGSize(width: 512, height: 256)
            
            
            let label = SKLabelNode()
                if action.rotate != 0 {
                    label.text = "\(index+1). Rotate \(action.rotate > 0 ? "right": "left") \(abs(action.rotate) == 1 ? "once" : "\(abs(action.rotate)) times")"
                } else {
                    label.text = "\(index+1). Forward \(abs(action.distance) == 1 ? "once" : "\(abs(action.distance)) times")"
                }
                label.fontName = "Nanum Pen"
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
            
            board.setScale(0.75 * 0.75)
            anchor?.addChild(board)
            listOfActions.append(board)
        }
    }
    
    func setActionFailure() {
        self.isUserInteractionEnabled = true
        if listOfActions.count > 0 {
            let label = listOfActions[0].children[0] as! SKLabelNode
            label.fontColor = UIColor.red
        }
        
        
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
    
    func hideSurfaceWarningBar() {
        let surfaceWarning = childNode(withName: "SurfaceWarning")!
        let moveIn = SKAction.moveTo(y: -1024, duration: 1)
        
        surfaceWarning.run(moveIn)
    }
    
    func showSideBar() {
        let drawer = childNode(withName: "//NextMovement")!
        let moveIn = SKAction.moveTo(x: 1366, duration: 1)
        moveIn.timingMode = .easeOut
        drawer.run(moveIn)
    }
    
    func hideSideBar() {
        let drawer = childNode(withName: "//NextMovement")!
        let moveIn = SKAction.moveTo(x: 1760, duration: 1)
        moveIn.timingMode = .easeOut
        drawer.run(moveIn)
    }
    
    func showWinPrompt() {
        let win = childNode(withName: "//Win")
        let scaleUp = SKAction.scale(to: 1, duration: 1)
        scaleUp.timingMode = .easeInEaseOut
        win?.run(scaleUp)
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
    
    //Detect presses on "Run" "Try Again" "Continue"
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let restartButton = childNode(withName: "//restart")!
        let startButton = childNode(withName: "//startButton")!
        let continueButton = childNode(withName: "//continue")!

        for touch in touches {
            let location = touch.location(in: self)
            if restartButton.contains(restartButton.parent!.convert(location, from: self)) {
                onLose()
            }
            
            if !isStarted && startButton.contains(startButton.parent!.convert(location, from: self)) {
                isStarted = true
                let startNode = childNode(withName: "//Start")
                startNode?.isHidden = true
                onStartButtonPressed()
            }
            
            if continueButton.contains(continueButton.parent!.convert(location, from: self)) {
                onWin()
            }
            
        }
    }
}
