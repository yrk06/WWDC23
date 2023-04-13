//
//  Level.swift
//  Pirate ARdventures Code Quest
//
//  Created by Yerik Koslowski on 05/04/23.
//


/// Class for defining game levels
class GameLevel {
    var elements : [BoardElement]
    var collisionTiles : [Int]
    var objective : BoardElement
    var playerStart : SIMD2<Int> = .zero
    
    init(elements: [BoardElement], objective: BoardElement) {
        self.elements = elements
        self.objective = objective
        collisionTiles = []
        
        for obstacle in elements {
            let bpos = obstacle.boardPosition
            let fpos = SIMD2<Int>(obstacle.boardPosition.x + obstacle.boardSize.x, obstacle.boardPosition.y + obstacle.boardSize.y)
            for y in bpos.y..<fpos.y {
                for x in bpos.x..<fpos.x {
                    collisionTiles.append(SzudzikMap(a: x, b: y))
                }
            }
        }
        
    }
}
