//
//  Kanji.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Translation

enum JLPTGrade: String, Decodable, CaseIterable {
    case N5
    case N4
    case N3
    case N2
    case N1
    
    var gradientColor: LinearGradient {
        switch self {
        case .N5:
            return LinearGradient(
                colors: [
                    Color.N5.main,
                    Color.N5.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .N4:
            return LinearGradient(
                colors: [
                    Color.N4.main,
                    Color.N4.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .N3:
            return LinearGradient(
                colors: [
                    Color.N3.main,
                    Color.N3.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .N2:
            return LinearGradient(
                colors: [
                    Color.N2.main,
                    Color.N2.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .N1:
            return LinearGradient(
                colors: [
                    Color.N1.main,
                    Color.N1.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var color: Color {
        switch self {
        case .N5: return Color.N5.main
        case .N4: return Color.N4.main
        case .N3: return Color.N3.main
        case .N2: return Color.N2.main
        case .N1: return Color.N1.main
        }
    }
}

struct Kanji: Decodable, Hashable {
    var id = UUID()
    
    let kanji: String // 한자
    let hiragana: String // 히라가나
    let meaningEn: String // 영어 뜻
    let meaningKo: String // 한글 뜻
    let grade: JLPTGrade // jlpt 급수
    
    var searchKey: String {
        return "\(kanji)\(hiragana)\(meaningKo)".lowercased()
    }
    
    enum CodingKeys: String, CodingKey {
        case kanji
        case hiragana
        case meaningEn
        case meaningKo
        case grade
    }
}

struct KanjiList: Hashable {
    let level: Int
    let kanjis: [Kanji]
}
