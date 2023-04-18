//
//  File.swift
//  
//
//  Created by Yerik Koslowski on 11/04/23.
//

import SceneKit
import SwiftUI

// Just a simple class to load the gameboard as a preview in the editor
class BoardPreview : SCNView {
    
    static func createBoardPreview(level: GameLevel, showTutorialLights: Bool = false) -> BoardPreview {
        let preview = BoardPreview()
        guard let sceneURL = Bundle.main.url(forResource: "BoardPreview", withExtension: "scn") else {
            fatalError("Unable to find BoardPreview.scn")
        }
        let sceneSource = SCNSceneSource(url: sceneURL, options: nil)
        guard let scene = sceneSource?.scene(options: nil) else {
            fatalError("Unable to load scene from myScene.scn")
        }
        
        preview.scene = scene
        
        if showTutorialLights {
            scene.rootNode.childNode(withName: "tutLight1", recursively: true)!.isHidden = false
            scene.rootNode.childNode(withName: "tutLight2", recursively: true)!.isHidden = false
        }
        
        let board = GameboardNode.newGameboard(hud: nil,level: level,instructions: [])
        
        
        scene.rootNode.addChildNode(board)
        
        return preview
    }
}

struct BoardPreviewView: UIViewRepresentable {
    
    var level: GameLevel
    var showTutorial: Bool
    
    func makeUIView(context: Context) -> SCNView {
        // configure your SCNView here
        return BoardPreview.createBoardPreview(level: level, showTutorialLights: showTutorial)
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // update your SCNView here
    }
}
