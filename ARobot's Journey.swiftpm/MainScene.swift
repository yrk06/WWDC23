import ARKit
import SceneKit

class ARController: UIViewController, ARSCNViewDelegate {
    let arView = ARSCNView(frame: .zero)
    
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
        
        let url = Bundle.main.url(forResource: "Gameboard", withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        referenceNode.simdPosition = SIMD3<Float>(planeAnchor.center.x, 0, planeAnchor.center.z)
        node.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
    }
}

