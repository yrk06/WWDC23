import ARKit
import SwiftUI
import SceneKit
import UIKit

struct BoardPossibleLocation {
    var node : SCNNode
    var gizmo : SCNNode
    var anchor: ARPlaneAnchor
}

class ARController: UIViewController, ARSCNViewDelegate {
    var arView = ARSCNView(frame: .zero)
    
    var editorView = Editor()
    var tutorialView = SKView(frame: .zero)
    var hostingController = UIHostingController(rootView: Editor())
    var board : GameboardNode?
    var possibleBoardLocations : [BoardPossibleLocation] = []
    var hud : BoardHud!
    
    var currentLevel = 0
    var levels : [GameLevel] = [
        GameLevel(elements: [
            BoardElement(boardPosition: SIMD2<Int>(6,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(4,4), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,6), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,3), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            BoardElement(boardPosition: SIMD2<Int>(1,0), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(3,8), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
        ],objective: BoardElement(boardPosition: SIMD2<Int>(0,1), boardSize: SIMD2<Int>(1,1), meshName: "chest")),
        
        GameLevel(elements: [
            BoardElement(boardPosition: SIMD2<Int>(6,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(4,4), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,6), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,3), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            BoardElement(boardPosition: SIMD2<Int>(1,0), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(3,8), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
        ],objective: BoardElement(boardPosition: SIMD2<Int>(8,1), boardSize: SIMD2<Int>(1,1), meshName: "chest"))
        
    ]
    
    // Create Views
#if targetEnvironment(simulator)
    var sceneView = SCNView(frame: .zero)
    func createSceneView() {
        
        print("aaaaaa")
        sceneView = SCNView(frame: .zero)
        self.view.addSubview(sceneView)
        
        guard let sceneURL = Bundle.main.url(forResource: "BoardPreview", withExtension: "scn") else {
            fatalError("Unable to find BoardPreview.scn")
        }
        let sceneSource = SCNSceneSource(url: sceneURL, options: nil)
        guard let scene = sceneSource?.scene(options: nil) else {
            fatalError("Unable to load scene from myScene.scn")
        }
        
        sceneView.scene = scene
        
        scaleView(sceneView)
        startAR()
    }
#endif
    
    func createArView () {
        arView = ARSCNView(frame: .zero)
        self.view.addSubview(arView);
        //arView.autoenablesDefaultLighting = false
        //arView.automaticallyUpdatesLighting = false
        arView.scene = SCNScene()
        arView.scene.rootNode.light = nil
        arView.delegate = self;
        arView.showsStatistics = true
        
        scaleView(arView)
        
        arView.contentMode = .scaleAspectFit
        arView.backgroundColor = .black
        
        
//        let skView = SKView(frame: .zero)
//        let scene = SKScene()
//        skView.showsFPS = true
//        skView.backgroundColor = .clear
//        scene.size = CGSize(width: 200, height: 200)
//        scene.scaleMode = .aspectFit
//        scene.backgroundColor = .systemTeal
//        skView.presentScene(scene)
        startAR()
        
        
    }
    
    func createEditorView() {
        //view = UIView(frame: .zero)
        pauseAR()
        editorView = Editor(run: runLevel, level: levels[currentLevel], instructions: instructionSet)
        hostingController = UIHostingController(rootView: editorView)
        
        scaleView(hostingController.view)
        
        hostingController.view.contentMode = .scaleAspectFit
        hostingController.view.backgroundColor = .black
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
    }
    
    func createTutorialView() {
        tutorialView.presentScene(TutorialOverlay.createTutorialOverlay())
        scaleView(tutorialView)
        tutorialView.backgroundColor = .black
        
        view.addSubview(tutorialView)
        
    }
    
    // VIEW SIZING
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        scaleView(hostingController.view)
        #if targetEnvironment(simulator)
        scaleView(sceneView)
        #else
        scaleView(arView)
        #endif
        scaleView(tutorialView)
        
    }
    
    func scaleView(_ v : UIView) {
        var size = UIScreen.main.bounds.size
        size.height -= 50
        let aspect = 2732/2048.0
        if size.width < size.height {
            v.frame = CGRect(x: 0, y: Double(size.height - size.width / aspect) / 2, width: size.width, height:size.width / aspect )
        } else {
            v.frame = CGRect(x: Double(size.width  - size.height * aspect) / 2, y:0, width: size.height * aspect, height:size.height )
        }
    }
    
    // STARTUP
    
    override func viewDidLoad() {
        view.backgroundColor = .black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        #if targetEnvironment(simulator)
            createSceneView()
        #else
            createArView()
        #endif
        createEditorView()
        createTutorialView()
        
        
        #if targetEnvironment(simulator)
        scaleView(sceneView)
        #else
        scaleView(arView)
        #endif
        scaleView(hostingController.view)
        scaleView(tutorialView)
        
    }
    
    
    
    
    var instructionSet : [PlayerAction] = []
    
    func runLevel(instructions: [PlayerAction]) {
        instructionSet = instructions
        
        hostingController.willMove(toParent: nil as UIViewController?)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
        view.bringSubviewToFront(arView)
        startAR()
    }
    
    func tryAgain() {
        createEditorView()
    }
    
    func nextLevel() {
        currentLevel += 1
        if currentLevel >= levels.count {
            //Endgame
        }
        instructionSet = []
        createEditorView()
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
        board = GameboardNode.newGameboard(hud: hud,level: levels[currentLevel], instructions: instructionSet)
        board!.simdPosition = SIMD3<Float>(anchor.center.x, 0, anchor.center.z)
        node.addChildNode(board!)
        hud.isUserInteractionEnabled = true
        hud.showSideBar()
    }
    
    func pauseAR() {
        arView.session.pause()
    }
    
#if targetEnvironment(simulator)
    func startAR() {
        board?.removeFromParentNode()
        
        hud = BoardHud.createHUD(reset: self.startAR, onStart: {
            self.board?.runGame()
        },onWin: nextLevel, onLose: tryAgain)
        board = GameboardNode.newGameboard(hud: hud, level: levels[currentLevel], instructions: instructionSet)
        sceneView.scene?.rootNode.addChildNode(board!)
        sceneView.overlaySKScene = hud
        hud.isUserInteractionEnabled = true
        hud.showSideBar()
    }
#else
    func startAR() {
        board?.removeFromParentNode()
        board = nil
        arView.session.pause()
        hud = BoardHud.createHUD(reset: self.startAR, onStart: {
            self.board?.runGame()
        },onWin: nextLevel, onLose: tryAgain)
        arView.overlaySKScene = hud
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Detect horizontal planes in the scene
        configuration.planeDetection = .horizontal
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
#endif
    
}
