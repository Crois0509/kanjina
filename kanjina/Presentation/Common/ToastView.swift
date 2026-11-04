//
//  ToastView.swift
//  kanjina
//
//  Created by 장상경 on 5/11/26.
//

import SwiftUI

/// 공용 토스트 메세지 뷰
struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .font(.shoraiSans(size: 14, weight: .regular))
            .foregroundStyle(.black)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(.white.opacity(0.9))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 4)
    }
}
