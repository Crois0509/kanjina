//
//  ProgressView.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import SwiftUI

/// 문제 상태
enum QuestionState: CaseIterable {
    case success
    case trial
    case fail
    
    var title: String {
        switch self {
        case .success: return "정답"
        case .trial: return "공부 필요"
        case .fail: return "모름"
        }
    }
    
    var isSuccessful: Bool {
        return self == .success
    }
}

/// 프로그레스 상태
struct ProgressState: Hashable {
    let id: Int
    var qState: QuestionState
}

/// 학습 진행도 그래프 뷰
struct LearningProgressView: View {
    
    let maxPoint: Int
    @Binding var current: [ProgressState]
    
    var body: some View {
        GeometryReader { geometry in
            let progressMaxWidth = geometry.size.width / CGFloat(maxPoint)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundStyle(.gray.opacity(0.5))
                    .frame(height: 8)
                
                HStack(spacing: 0) {
                    ForEach(current, id: \.id) { state in
                        Rectangle()
                            .foregroundStyle(setProgressColor(state))
                            .frame(maxWidth: progressMaxWidth)
                    }
                }
                .animation(.linear(duration: 0.5), value: current)
            }
            .clipShape(Capsule())
            .clipped()
        }
        .frame(height: 8)
    }
    
    func setProgressColor(_ state: ProgressState) -> Color {
        switch state.qState {
        case .success: return .blue
        case .trial: return .yellow
        case .fail: return .red
        }
    }
}
