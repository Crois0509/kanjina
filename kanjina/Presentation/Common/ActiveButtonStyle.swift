//
//  ActiveButtonStyle.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

/// 공용 버튼 스타일
struct ActiveButtonStyle: ButtonStyle {
    
    @Binding var isDisabled: Bool
    let color: Color
    
    init(isDisabled: Bool, color: Color) {
        self._isDisabled = .constant(isDisabled)
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.shoraiSans(size: 18, weight: .demi))
            .foregroundStyle(color)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 1.0)
                    .foregroundStyle(.clear)
            }
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
