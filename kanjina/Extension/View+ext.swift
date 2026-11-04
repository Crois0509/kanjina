//
//  View+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/16/26.
//

import SwiftUI

extension View {
    
    /// 키보드를 명시적으로 숨기기 위한 편의 메서드
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
