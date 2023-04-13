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
    
    static func createTutorialOverlay() -> TutorialOverlay {
        let scene = TutorialOverlay(fileNamed: "TutorialOverlay")!
        scene.scaleMode = .fill
        scene.backgroundColor = .clear
        return scene
    }
    
    private func initializeState() {
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
    }
    
    func runQuickTutorial() {
        currentState = "QuickTutorial"
        currentScene = 0
        initializeState()
    }
    
    func runChallenge() {
        currentState = "EntryScene"
        currentScene = 0
        initializeState()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let sceneOut = childNode(withName: "./\(currentState)/Scene\(currentScene)")!
        sceneOut.run(SKAction.fadeOut(withDuration: 0.5))
        currentScene += 1
        let sceneIn = childNode(withName:  "./\(currentState)/Scene\(currentScene)" )
        
        sceneIn?.run(SKAction.fadeIn(withDuration: 0.5))
        
        if sceneIn == nil {
            //my work is done here
            let node = childNode(withName: "//\(currentState)")!
            node.run(SKAction.fadeOut(withDuration: 0.2))
            self.view?.backgroundColor = .clear
            self.view?.isUserInteractionEnabled = false
        }
    }
}
