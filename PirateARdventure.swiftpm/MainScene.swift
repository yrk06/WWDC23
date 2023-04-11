import ARKit
import SceneKit

struct BoardPossibleLocation {
    var node : SCNNode
    var gizmo : SCNNode
    var anchor: ARPlaneAnchor
}

class ARController: UIViewController, ARSCNViewDelegate {
    var arView = ARSCNView(frame: .zero)
    var board : GameboardNode?
    var possibleBoardLocations : [BoardPossibleLocation] = []
    var hud : BoardHud!
    
    func createArView () {
        arView = ARSCNView(frame: .zero)
        self.view = arView;
        //arView.autoenablesDefaultLighting = false
        //arView.automaticallyUpdatesLighting = false
        arView.scene = SCNScene()
        arView.scene.rootNode.light = nil
        arView.delegate = self;
        arView.showsStatistics = true
        //restart()
        
        
        let skView = SKView(frame: .zero)
        let scene = SKScene()
        skView.showsFPS = true
        skView.backgroundColor = .clear
        scene.size = CGSize(width: 200, height: 200)
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .systemTeal
        skView.presentScene(scene)
//        skView.translatesAutoresizingMaskIntoConstraints = false
//        arView.addSubview(skView)
//
//        NSLayoutConstraint.activate([
//            skView.topAnchor.constraint(equalTo: arView.topAnchor),
//            skView.leadingAnchor.constraint(equalTo: arView.leadingAnchor),
//            skView.trailingAnchor.constraint(equalTo: arView.trailingAnchor),
//            skView.bottomAnchor.constraint(equalTo: arView.bottomAnchor),
//        ])
        
        
        
        
    }
    
    override func viewDidLoad() {
        
        var cfURL = Bundle.main.url(forResource: "Sketchbones-RpeE", withExtension: "ttf")! as CFURL
        CTFontManagerRegisterFontsForURL(cfURL, CTFontManagerScope.process, nil)
        cfURL = Bundle.main.url(forResource: "TreasureMapDeadhand-yLA3", withExtension: "ttf")! as CFURL
        CTFontManagerRegisterFontsForURL(cfURL, CTFontManagerScope.process, nil)
        
        
        createArView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Create a session configuration
        restart()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if board != nil {
            return
        }
        
        
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
        board = GameboardNode.newGameboard(hud: hud)
        board!.simdPosition = SIMD3<Float>(anchor.center.x, 0, anchor.center.z)
        node.addChildNode(board!)
        hud.isUserInteractionEnabled = true
        hud.showSideBar()
    }
    
    func restart() {
        board?.removeFromParentNode()
        board = nil
        arView.session.pause()
        hud = BoardHud.createHUD(reset: self.restart, onStart: {
            self.board?.runGame()
        })
        arView.overlaySKScene = hud
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Detect horizontal planes in the scene
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
}
