//
//  CommonCapsuleView.swift
//  kanjina
//
//  Created by 장상경 on 5/16/26.
//

import SwiftUI

/// 공용 캡슐 뷰
struct CommonCapsuleView: View {
    
    let title: String
    let textColor: Color
    let bgColor: Color
    
    var body: some View {
        Text(title)
            .font(.shoraiSans(size: 14, weight: .regular))
            .foregroundStyle(textColor)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(bgColor)
            .clipShape(Capsule())
    }
}
