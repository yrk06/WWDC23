//
//  File.swift
//  
//
//  Created by Yerik Koslowski on 11/04/23.
//

import SceneKit
import SwiftUI

class BoardPreview : SCNView {
    
    static func createBoardPreview() -> BoardPreview {
        let preview = BoardPreview()
        guard let sceneURL = Bundle.main.url(forResource: "BoardPreview", withExtension: "scn") else {
            fatalError("Unable to find BoardPreview.scn")
        }
        let sceneSource = SCNSceneSource(url: sceneURL, options: nil)
        guard let scene = sceneSource?.scene(options: nil) else {
            fatalError("Unable to load scene from myScene.scn")
        }
        
        preview.scene = scene
        
        let board = GameboardNode.newGameboard(hud: nil)
        
        scene.rootNode.addChildNode(board)
        
        return preview
    }
}

struct BoardPreviewView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        // configure your SCNView here
        return BoardPreview.createBoardPreview()
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // update your SCNView here
    }
}
