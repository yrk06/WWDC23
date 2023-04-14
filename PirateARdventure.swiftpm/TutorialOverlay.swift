//
//  TutorialOverlay.swift
//  Pirate ARdventures Code Quest
//
//  Created by Yerik Koslowski on 13/04/23.
//

import SpriteKit

class TutorialOverlay : SKScene {
    
    var currentState = "EntryScene"
    var currentScene = 0
    var thisIsTheLastScreen = false
    
    var onEnd: (()->Void) = {}
    
    static func createTutorialOverlay() -> TutorialOverlay {
        let scene = TutorialOverlay(fileNamed: "TutorialOverlay")!
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        return scene
    }
    
    private func initializeState(bgColor : UIColor = .black ) {
        self.view?.backgroundColor = bgColor
        self.view?.isUserInteractionEnabled = true
        let node = childNode(withName: "//\(currentState)")!
        node.run(SKAction.fadeIn(withDuration: 0.2))
        let sceneIn = childNode(withName:  "./\(currentState)/Scene\(currentScene)" )!
        
        sceneIn.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    func runOnboarding() {
        currentState = "EntryScene"
        currentScene = 0
        initializeState()
        onEnd = runQuickTutorial
    }
    
    func runQuickTutorial() {
        currentState = "FirstLevelTutorial"
        currentScene = 0
        initializeState(bgColor: .clear)
    }
    
    func runPostFirstLevel() {
        currentState = "EndTutorial1Scene"
        currentScene = 0
        initializeState()
    }
    
    func runPostSecondLevel() {
        currentState = "EndTutorial2Scene"
        currentScene = 0
        initializeState()
    }
    
    func runChallenge() {
        currentState = "EndTutorial1Scene"
        currentScene = 0
        initializeState()
    }
    
    func finalScreen() {
        currentState = "FinalGameScene"
        currentScene = 0
        thisIsTheLastScreen = true
        initializeState()
    }
    
    // Walk over the currentState scenes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sceneIn = childNode(withName:  "./\(currentState)/Scene\(currentScene + 1)" )
        if thisIsTheLastScreen && sceneIn == nil {
            self.isUserInteractionEnabled = false
            return
        }
        let sceneOut = childNode(withName: "./\(currentState)/Scene\(currentScene)")!
        sceneOut.run(SKAction.fadeOut(withDuration: 0.5))
        currentScene += 1
        
        
        sceneIn?.run(SKAction.fadeIn(withDuration: 0.5))
        
        if sceneIn == nil {
            //my work is done here
            let node = childNode(withName: "//\(currentState)")!
            node.run(SKAction.fadeOut(withDuration: 0.2))
            self.view?.backgroundColor = .clear
            self.view?.isUserInteractionEnabled = false
            
            onEnd()
            onEnd = {}
        }
    }
}
