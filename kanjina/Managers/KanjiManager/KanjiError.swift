//
//  KanjiError.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import Foundation

enum KanjiError: LocalizedError {
    case fileNotFound
    case dataConversionFail
    case decodingFail
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "❌ 오류: 번들에서 JLPT 파일을 찾을 수 없습니다."
        case .dataConversionFail:
            return "❌ 오류: 파일에서 데이터를 로드할 수 없습니다."
        case .decodingFail:
            return "❌ 오류: 디코딩에 실패했습니다."
        }
    }
}
