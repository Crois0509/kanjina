//
//  Date+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import Foundation

extension Date {
    /// Date 타입을 [yyyy년 MM월 dd일] 형식으로 변경하기 위한 공유 Formatter
    fileprivate var yearMonthDayStringDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = .init(identifier: "ko_KR")
        return formatter
    }
    
    /// Date 타입을 [MM/dd] 형식으로 변경하기 위한 공유 Formatter
    fileprivate var shotStringFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = .init(identifier: "ko_KR")
        return formatter
    }
    
    /// Date 타입을 연/월/일 형식의 String 타입으로 변경해주는 편의 메서드
    ///
    /// **Formatter 형식**: yyyy년 MM월 dd일
    var yearMonthDayStringFormat: String {
        return yearMonthDayStringDateFormatter.string(from: self)
    }
    
    /// Date 타입을 월/일 형식의 String 타입으로 변경해주는 편의 메서드
    ///
    /// **Formatter 형식**: MM/dd
    var shotStringFormat: String {
        return shotStringFormatter.string(from: self)
    }
}
