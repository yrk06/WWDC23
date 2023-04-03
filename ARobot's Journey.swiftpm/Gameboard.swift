//
//  Gameboard.swift
//  ARobot's Journey
//
//  Created by Yerik Koslowski on 01/04/23.
//
import SceneKit

class GameboardNode : SCNNode {
    
    
    static func newGameboard() -> SCNNode {
        let node = GameboardNode()
        let url = Bundle.main.url(forResource: "Gameboard", withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        node.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
        //let water = node.childNode(withName: "Water", recursively: true)!
        //let shader = try! String(contentsOf: Bundle.main.url(forResource: "water", withExtension: "shader")! )
        /*water.geometry?.materials.first?.shaderModifiers = [
            .surface : shader
        ]*/
        
        let ship = node.childNode(withName: "ship_light_wood", recursively: true)
        
        /*let floatAnimation = CABasicAnimation(keyPath: "transform.position.y")
        floatAnimation.fromValue = 0
        floatAnimation.toValue = 0.003
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = .infinity
        floatAnimation.duration = 2
        floatAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        ship?.addAnimation(floatAnimation, forKey: nil)*/
        
        let rockAnimation = CABasicAnimation(keyPath: "transform.euler.z")
        rockAnimation.fromValue = (-7 * Float.pi) / 180
        rockAnimation.toValue = (7 * Float.pi) / 180
        rockAnimation.autoreverses = true
        rockAnimation.repeatCount = .infinity
        rockAnimation.duration = 5
        rockAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        //ship?.addAnimation(floatAnimation, forKey: nil)
        ship?.addAnimation(rockAnimation, forKey: nil)
        return node
    }
}
