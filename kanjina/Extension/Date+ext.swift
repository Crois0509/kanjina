//
//  Date+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import Foundation

extension Date {
    fileprivate var yearMonthDayStringDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        formatter.locale = .init(identifier: "ko_KR")
        return formatter
    }
    
    fileprivate var shotStringFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = .init(identifier: "ko_KR")
        return formatter
    }
    
    var yearMonthDayStringFormat: String {
        return yearMonthDayStringDateFormatter.string(from: self)
    }
    
    var shotStringFormat: String {
        return shotStringFormatter.string(from: self)
    }
}
