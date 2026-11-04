//
//  SmoothAnimationButtonStyle.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

/// 공용 버튼 뷰(부드러운 애니메이션 적용)
struct SmoothAnimationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
