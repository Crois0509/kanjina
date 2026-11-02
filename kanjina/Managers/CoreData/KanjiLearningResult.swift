//
//  KanjiLearningResult.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import Foundation

struct KanjiLearningResult: Hashable {
    let id = UUID()
    let kanji: Kanji
    let level: Int
    var state: QuestionState
    var bookmark: Bool
}
