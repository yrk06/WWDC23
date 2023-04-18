//
//  File.swift
//  
//
//  Created by Yerik Koslowski on 03/04/23.
//
import SceneKit

// An instruction for the ship
struct PlayerAction: Identifiable {
    
    var id = UUID()
    
    var distance : Int
    var rotate: Int
    
    func getLabel() -> String {
        if rotate != 0 {
            return "Rotate \(rotate > 0 ? "right" : "left")"
        } else {
            return "Move forward"
        }
    }
    
    func getMagnitude() -> Int {
        return max(distance, abs(rotate))
    }
    
    func getColor() -> Int {
        if rotate != 0 {
            return rotate > 0 ? 1: 2
        } else {
            return 0
        }
    }
    
    mutating func increaseMagnitude() {
        if rotate != 0 {
            if rotate > 0 {
                rotate += 1
            } else {
                rotate -= 1
            }
            rotate = rotate > 4 ? 4 : rotate
        } else {
            distance += 1
            distance = distance > 8 ? 8 : distance
        }
    }
    
    mutating func decreaseMagnitude() -> Bool {
        if rotate != 0 {
            if rotate > 0 {
                rotate -= 1
            } else {
                rotate += 1
            }
            return rotate == 0
        } else {
            distance -= 1
            return distance == 0
        }
    }
}

// The ship
class PlayerController : SCNNode {
    var boardPosition : SIMD2<Int>

    
    init(at: SIMD2<Int>, rotated: Float) {
        self.boardPosition = at
        super.init()
        
        // Load player ship
        let url = Bundle.main.url(forResource: "Player", withExtension: "scn" )!
        let referenceNode = SCNReferenceNode(url: url)!
        self.addChildNode(referenceNode)
        SCNTransaction.begin()
        referenceNode.load()
        SCNTransaction.commit()
        
        let scenePos = board2scene(from: boardPosition)
        self.position.x =  scenePos.x
        self.position.y = 0.007
        self.position.z =  scenePos.z
        
        self.eulerAngles.y = rotated
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var particlesInit = false
    func initParticleTrail() {
        if particlesInit {
            return
        }
        particlesInit = true
        let particle = childNode(withName: "particles", recursively: true)!.particleSystems?.first
        particle?.birthRate = 15
        
    }
    
    // Rotate the ship
    func updateRotation(rotation: Int) async {
        initParticleTrail()
        let angle = -.pi / 2 * Float(rotation)
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(angle), z: 0, duration: Double(abs(rotation)) * 3.0)
        rotationAction.timingMode = .easeInEaseOut
        await self.runAction(rotationAction)
    }
    
    // Move ship forward
    func updatePosition(tiles: Int, isFirst : Bool = false, isLast : Bool = false) async {
        initParticleTrail()
        let to = getForwardPosition(tiles: tiles)
        
        self.boardPosition = to
        
        var scenePos = board2scene(from: to)
        scenePos.y = self.position.y
        let moveDistance = distance(SIMD3<Float>(self.position.x,self.position.y, self.position.z), scenePos) / 0.2 * 15 // Normalize distance
        let movement = SCNAction.move(to: SCNVector3(scenePos.x, self.position.y, scenePos.z), duration: Double(moveDistance))
        
        movement.timingMode = .linear
        if isFirst {
            movement.timingMode = .easeIn
        }
        if isLast {
            movement.timingMode = .easeOut
        }
        
        await self.runAction(movement)
    }
    
    // Functions to convert from ship coordinates into board coordinates
    
    func getForwardPosition(tiles: Int) -> SIMD2<Int> {
        
        //Convert forward vector to scene coordinates
        let worldForward = self.convertVector(SCNVector3(0, 0, -1 * tiles), to: self.parent)
        
        //Forward in Board Pos
        return SIMD2<Int>(Int(round(worldForward.x)) + self.boardPosition.x,
                            Int(round(worldForward.z)) + self.boardPosition.y)
    }
    
    func getPlayerForwardVector() -> SCNVector3 {
        return self.convertVector(SCNVector3(0, 0, -1), to: self.parent)
    }
    
    func getPlayerRightVector() -> SCNVector3 {
        return self.convertVector(SCNVector3(1, 0, 0), to: self.parent)
    }
    
    
    
    
}
