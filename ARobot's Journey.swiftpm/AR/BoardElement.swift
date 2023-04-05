//
//  File.swift
//  
//
//  Created by Yerik Koslowski on 03/04/23.
//
import SceneKit

struct BoardElement {
    let boardPosition : SIMD2<Int>
    let boardSize : SIMD2<Int>
    let meshName  : String
}

//class BoardElement : SCNNode {
//    let boardPosition : SIMD2<Int>
//    let boardPositionIndex : Int
//    let
//
//    init(boardPosition: SIMD2<Int>, elementSize : SIMD2<Int>)
//    {
//        self.boardPosition = boardPosition
//        self.boardPositionIndex = SzudzikMap(a: boardPosition.x, b: boardPosition.y);
//        super.init()
//
//        let scenePos = board2scene(from: boardPosition)
//        self.position.x =  scenePos.x
//        self.position.y = 0.003
//        self.position.z =  scenePos.z
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
