import ARKit
import SwiftUI
import SceneKit
import UIKit

/// Structure to keep track of AR Anchors
struct BoardPossibleLocation {
    var node : SCNNode
    var gizmo : SCNNode
    var anchor: ARPlaneAnchor
}

/// The main view controller, this class manages the entire game
class ARController: UIViewController, ARSCNViewDelegate {
    
    // The 3 main views used for the game
    var arView = ARSCNView(frame: .zero)
    var editorView = Editor()
    var tutorialView = SKView(frame: .zero)
    var tutorialOverlay = TutorialOverlay()
    
    var hostingController = UIHostingController(rootView: Editor())
    
    // References to the game objects
    var board : GameboardNode?
    var possibleBoardLocations : [BoardPossibleLocation] = []
    var hud : BoardHud!
    // These are the instructions that the boat will run
    var instructionSet : [PlayerAction] = [PlayerAction(distance: 2, rotate: 0)]
    
    var queuePlayer = AVQueuePlayer()
    var playerLooper: AVPlayerLooper?
    
    var queuePlayerBg = AVQueuePlayer()
    var playerLooperBg: AVPlayerLooper?
    
    // Levels
    // Do edit/duplicate/add new levels if you wish to create custom levels ;)
    var currentLevel = 0
    var levels : [GameLevel] = [
        
        // Level 1
        GameLevel(
            elements: [
            BoardElement(boardPosition: SIMD2<Int>(0,7), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(7,7), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            
            BoardElement(boardPosition: SIMD2<Int>(2,6), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            BoardElement(boardPosition: SIMD2<Int>(6,6), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            
            BoardElement(boardPosition: SIMD2<Int>(3,5), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(5,5), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            
            BoardElement(boardPosition: SIMD2<Int>(2,3), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(5,3), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
        ],
            objective: BoardElement(boardPosition: SIMD2<Int>(4,3), boardSize: SIMD2<Int>(1,1), meshName: "chest"),
            playerStart: SIMD2<Int>(4,8),
            playerRotation: 0
        ),
        
        // Level 2
        GameLevel(
            elements: [
            BoardElement(boardPosition: SIMD2<Int>(0,7), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(7,7), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            
            BoardElement(boardPosition: SIMD2<Int>(2,6), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            BoardElement(boardPosition: SIMD2<Int>(6,6), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            
            BoardElement(boardPosition: SIMD2<Int>(3,5), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(5,5), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            
            BoardElement(boardPosition: SIMD2<Int>(3,4), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(5,3), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(3,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
        ],
            objective: BoardElement(boardPosition: SIMD2<Int>(2,3), boardSize: SIMD2<Int>(1,1), meshName: "chest"),
            playerStart: SIMD2<Int>(4,8),
            playerRotation: 0
        ),
        
        // Level 3
        GameLevel(elements: [
            BoardElement(boardPosition: SIMD2<Int>(6,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(4,4), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,6), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,1), boardSize: SIMD2<Int>(2,2), meshName: "tower"),
            BoardElement(boardPosition: SIMD2<Int>(1,3), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            BoardElement(boardPosition: SIMD2<Int>(1,0), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(3,8), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
            BoardElement(boardPosition: SIMD2<Int>(7,6), boardSize: SIMD2<Int>(1,1), meshName: "rock"),
            BoardElement(boardPosition: SIMD2<Int>(6,3), boardSize: SIMD2<Int>(1,1), meshName: "stone"),
        ],
                  objective: BoardElement(boardPosition: SIMD2<Int>(8,1), boardSize: SIMD2<Int>(1,1), meshName: "chest"))
//                  objective: BoardElement(boardPosition: SIMD2<Int>(0,1), boardSize: SIMD2<Int>(1,1), meshName: "chest"))
        
    ]
    
    // Create the main Views
#if targetEnvironment(simulator)
    // Camera is not available on the emulators, thus in that case we make a simplified top-down view for testing purposes
    var sceneView = SCNView(frame: .zero)
    func createSceneView() {
        
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
    
    // Create the main ARView for the board
    func createArView () {
        arView = ARSCNView(frame: .zero)
        self.view.addSubview(arView);
        arView.scene = SCNScene()
        arView.scene.rootNode.light = nil
        arView.delegate = self;
        arView.showsStatistics = true
        
        scaleView(arView)
        
        arView.contentMode = .scaleAspectFit
        arView.backgroundColor = .black
        
        startAR()
    }
    
    // The instruction editor view
    func createEditorView() {
        pauseAR() // Save a few resources... I hope
        
        editorView = Editor(run: runLevel, level: levels[currentLevel], isTutorial: (currentLevel == 0), instructions: instructionSet )
        
        /* Editor View is a swiftUI View so I need to wrap it
         * Yes, it's a swiftUI being wrapped into a UIView in a
         * ViewController that is also being wrapped in a swiftUI view
         * Hopefully that impact the performance too much
         */
        hostingController = UIHostingController(rootView: editorView)
        scaleView(hostingController.view)
        
        // Some properties that need to be set and functions that need to be called
        hostingController.view.contentMode = .scaleAspectFit
        hostingController.view.backgroundColor = .black
        addChild(hostingController)
        view.insertSubview(hostingController.view, belowSubview: tutorialView)
        hostingController.didMove(toParent: self)
        hostingController.view.frame = view.bounds
    }
    
    // The tutorial view
    func createTutorialView() {
        tutorialOverlay = TutorialOverlay.createTutorialOverlay()
        tutorialView.presentScene(tutorialOverlay)
        scaleView(tutorialView)
        tutorialView.backgroundColor = .black
        tutorialOverlay.runOnboarding()
        
        view.addSubview(tutorialView)
        
    }
    
    // VIEW SIZING
    
    // Make sure the frame sizes are all updated when the screen is rotated
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if size.width < size.height {
            tutorialOverlay.showLanscapeWarning()
        } else {
            tutorialOverlay.hideLanscapeWarning()
        }
        
        scaleView(hostingController.view)
        #if targetEnvironment(simulator)
        scaleView(sceneView)
        #else
        scaleView(arView)
        #endif
        scaleView(tutorialView)
        
    }
    
    // Calculate the width and height based on an Ipad Pro Aspect ratio
    func scaleView(_ v : UIView) {
        let width = UIScreen.main.bounds.width
        var height = UIScreen.main.bounds.height
        height -= view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 24
        v.frame = CGRect(x: 0, y: 0, width: width, height: height)
        v.contentMode = .scaleAspectFit
    }
    
    // STARTUP
    
    override func viewDidLoad() {
        view.backgroundColor = .black
        
        let oceanurl = Bundle.main.url(forResource: "Ocean3", withExtension: "wav")!
        let oceanItem = AVPlayerItem(asset: AVAsset(url: oceanurl))
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: oceanItem)
        queuePlayer.play()
        queuePlayer.volume = 2
        
        let bgurl = Bundle.main.url(forResource: "Music", withExtension: "wav")!
        let bgItem = AVPlayerItem(asset: AVAsset(url: bgurl))
        playerLooperBg = AVPlayerLooper(player: queuePlayerBg, templateItem: bgItem)
        queuePlayerBg.play()
        queuePlayerBg.volume = 0.2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // These views are all stacked, we only show/hide whenever we need navigation
        #if targetEnvironment(simulator)
            createSceneView()
        #else
            createArView()
        #endif
        createTutorialView()
        createEditorView()
        
        
        // Make sure to properly set their frames
        #if targetEnvironment(simulator)
        scaleView(sceneView)
        #else
        scaleView(arView)
        #endif
        scaleView(hostingController.view)
        scaleView(tutorialView)
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        if width < height {
            tutorialOverlay.showLanscapeWarning()
        } else {
            tutorialOverlay.hideLanscapeWarning()
        }
    }
    
    // GameLogic
    
    // start the AR (or 3D scene in simulator) with the instructions and the level
    func runLevel(instructions: [PlayerAction]) {
        instructionSet = instructions
        
        hostingController.willMove(toParent: nil as UIViewController?)
        hostingController.view.removeFromSuperview()
        hostingController.removeFromParent()
        startAR()
        
        
    }
    
    // Game callback if the player gets the objective or not
    func tryAgain() {
        createEditorView()
    }
    
    func nextLevel() {
        currentLevel += 1
        instructionSet = []
        if currentLevel == 0 {
            tutorialOverlay.runQuickTutorial()
        }
        
        if currentLevel == 1 {
            tutorialOverlay.runPostFirstLevel()
            instructionSet.append(PlayerAction(distance: 5, rotate: 0))
        }
        if currentLevel == 2 {
            tutorialOverlay.runPostSecondLevel()
            
        }
        if currentLevel >= 3 {
            tutorialOverlay.finalScreen()
            currentLevel = 0
        }
        
        createEditorView()
    }
    
    
    // This is called when ARKit finds a new anchor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if board != nil {
            return
        }
        
        /* There is some logic to show a "start" button
         * this is done in order to let the player choose
         * which surface they want to place the board in.
         */
        let url = Bundle.main.url(forResource: "BoardStart", withExtension: "scn" )!
        let sphere = SCNReferenceNode(url: url)!
        SCNTransaction.begin()
        sphere.load()
        SCNTransaction.commit()
        
        sphere.simdPosition = SIMD3<Float>(planeAnchor.center.x,0.05,planeAnchor.center.z)
        node.addChildNode(sphere)
        
        //Save this as one of the possible locations
        possibleBoardLocations.append(BoardPossibleLocation(node: node, gizmo: sphere, anchor: planeAnchor))
    }
    
    // Detect when one of the possible locations was choosen
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
        hud.hideSurfaceWarningBar()
    }
    
    
    func pauseAR() {
        arView.session.pause()
    }
    
#if targetEnvironment(simulator)
    // Mock the AR for the simulator
    func startAR() {
        board?.removeFromParentNode()
        
        hud = BoardHud.createHUD(levelNumber: currentLevel, reset: self.startAR, onStart: {
            self.board?.runGame()
        },onWin: nextLevel, onLose: tryAgain)
        board = GameboardNode.newGameboard(hud: hud, level: levels[currentLevel], instructions: instructionSet)
        sceneView.scene?.rootNode.addChildNode(board!)
        sceneView.overlaySKScene = hud
        hud.isUserInteractionEnabled = true
        hud.showSideBar()
        hud.hideSurfaceWarningBar()
    }
#else
    func startAR() {
        // Remove the old board
        board?.removeFromParentNode()
        board = nil
        arView.session.pause()
        
        // Add a new hud
        hud = BoardHud.createHUD(levelNumber: currentLevel, reset: self.startAR, onStart: {
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
