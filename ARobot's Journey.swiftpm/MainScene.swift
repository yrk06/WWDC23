import ARKit
import SceneKit

struct BoardPossibleLocation {
    var node : SCNNode
    var gizmo : SCNNode
    var anchor: ARPlaneAnchor
}

class ARController: UIViewController, ARSCNViewDelegate {
    let arView = ARSCNView(frame: .zero)
    var board : SCNNode?
    var possibleBoardLocations : [BoardPossibleLocation] = []
    
    override func viewDidLoad() {
        self.view = arView;
        arView.scene = SCNScene()
        arView.autoenablesDefaultLighting = true
        arView.delegate = self;
        arView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Detect horizontal planes in the scene
        configuration.planeDetection = .horizontal

        // Run the view's session
        arView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        
        let url = Bundle.main.url(forResource: "BoardStart", withExtension: "scn" )!
        let sphere = SCNReferenceNode(url: url)!
        SCNTransaction.begin()
        sphere.load()
        SCNTransaction.commit()
        
        //let sphere = SCNNode(geometry: SCNSphere(radius: 0.05))
        sphere.simdPosition = SIMD3<Float>(planeAnchor.center.x,0.05,planeAnchor.center.z)
        node.addChildNode(sphere)
        possibleBoardLocations.append(BoardPossibleLocation(node: node, gizmo: sphere, anchor: planeAnchor))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard board == nil else {
            return
        }
        guard let touchLocation = touches.first?.location(in: arView),
        let result = arView.hitTest(touchLocation, options: nil).first else {
                    return
        }
        let resultNode = result.node
        //result.node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        let anchorInfo = possibleBoardLocations.first(where: {$0.gizmo == resultNode.parent?.parent})
        
        
        possibleBoardLocations.forEach({$0.gizmo.removeFromParentNode()})
        possibleBoardLocations.removeAll(where: {_ in true})
        
        createGameboard(node: anchorInfo!.node, anchor: anchorInfo!.anchor)
    }
    
    func createGameboard(node: SCNNode, anchor: ARPlaneAnchor) {
        board = GameboardNode.newGameboard()
        board!.simdPosition = SIMD3<Float>(anchor.center.x, 0, anchor.center.z)
        node.addChildNode(board!)
    }
}

