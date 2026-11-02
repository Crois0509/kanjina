//
//  OnboardingView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

struct OnboardingView: View {
        
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.N4.main,
                    Color.N4.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .center, spacing: 12) {
                Image(.logo)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.5), lineWidth: 0.5)
                    )
                    .padding(.bottom, 40)
                
                Text("칸지-나")
                    .foregroundStyle(.white)
                    .font(.shoraiSans(size: 48, weight: .black))
                
                Text("JLPT 공부도 칸지-나로 칸지나게")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.shoraiSans(size: 16, weight: .medium))
            }
            .padding(.bottom, 120)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
}
