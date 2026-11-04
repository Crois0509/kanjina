//
//  Int+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import Foundation

extension Int {
    
    /// Int 값을 분/초로 바꾸기 위한 편의 메서드
    var formatTime: String {
        let m = self / 60
        let s = self % 60
        return String(format: "%02d분 %02d초", m, s)
    }
}
