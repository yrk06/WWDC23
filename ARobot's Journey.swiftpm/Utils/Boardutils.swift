//
//  File.swift
//  
//
//  Created by Yerik Koslowski on 03/04/23.
//

func SzudzikMap(a: Int, b: Int) -> Int {
    guard a >= 0 && b >= 0 else {
        return -1
    }
    
    return a >= b ? a * a + a + b : a + b * b;
}

func board2scene(from: SIMD2<Int>) -> SIMD3<Float> {
    return SIMD3<Float>( -0.08 + 0.02 * Float(from.x), 0, -0.08 + 0.02 * Float(from.y))
}

extension RandomAccessCollection {

    func binarySearch(predicate: (Iterator.Element) -> Bool) -> Bool {
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high)/2)
            if predicate(self[mid]) {
                return true
            } else {
                high = mid
            }
        }
        return false
    }
}
