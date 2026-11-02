//
//  Array+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/12/26.
//

import Foundation

extension Array where Element == Kanji {
    func removingDuplicates() -> [Kanji] {
        var seen = Set<String>()
        return filter { seen.insert($0.kanji).inserted }
    }
}
