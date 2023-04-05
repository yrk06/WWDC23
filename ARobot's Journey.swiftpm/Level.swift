//
//  Level.swift
//  Pirate ARdventures Code Quest
//
//  Created by Yerik Koslowski on 05/04/23.
//

class GameLevel {
    var elements : [BoardElement]
    var collisionTiles : [Int]
    
    init(elements: [BoardElement]) {
        self.elements = elements
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
