//
//  Array+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/12/26.
//

import Foundation

extension Array where Element == Kanji {
    
    /// [Kanji] 배열에서 중복을 제거하는 편의 메서드
    /// - Returns: 중복이 제거된 [Kanji] 배열
    func removingDuplicates() -> [Kanji] {
        var seen = Set<String>()
        return filter { seen.insert($0.kanji).inserted }
    }
}
