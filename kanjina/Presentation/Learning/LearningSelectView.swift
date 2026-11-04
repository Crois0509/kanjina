//
//  ContentView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

// MARK: - LearningSelect View

struct LearningSelectView: View {
    
    @EnvironmentObject private var coordinator: LearningCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    @State private var isShowingAlert: Bool = false
    @State private var selectJlpt: Int = 0
    @State private var selectLevel: Int = 0
    
    var body: some View {
        ZStack {
            // Main
            VStack(alignment: .leading, spacing: 0) {
                Text("급수별 단어 학습")
                    .foregroundStyle(Color.black)
                    .font(.shoraiSans(size: 32, weight: .bold))
                    .padding(.bottom, 8)
                
                Text("원하는 급수를 선택하고 레벨별로 단어를 학습하세요!")
                    .foregroundStyle(Color.secondary)
                    .font(.shoraiSans(size: 16, weight: .regular))
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.state.numberOfKanjiByGrade.indices, id: \.self) { index in
                            let grade = JLPTGrade.allCases[index]
                            let totalKanjiCount = viewModel.state.numberOfKanjiByGrade[index]
                            
                            Button {
                                isShowingAlert = true
                                selectJlpt = index
                                
                            } label: {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 16)
                                        .foregroundStyle(grade.gradientColor)
                                        .shadow(color: .black.opacity(0.2), radius: 2)
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("\(grade.rawValue)급")
                                            .foregroundStyle(Color.white)
                                            .font(.shoraiSans(size: 20, weight: .bold))
                                        
                                        Text("필수 단어 \(totalKanjiCount)자")
                                            .foregroundStyle(Color.white)
                                            .font(.shoraiSans(size: 14, weight: .medium))
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 14)
                                }
                            }
                            .buttonStyle(SmoothAnimationButtonStyle())
                            .padding(.horizontal, 4)
                        }
                        .padding(.top, 16)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .disabled(isShowingAlert)
            .padding(.top, 10)
            .padding(.horizontal, 20)
            
            // Level Select Alert
            PickerAlertView(
                isShowing: $isShowingAlert,
                selection: $selectLevel,
                title: "몇 단계 문제를 풀어볼까요?",
                content: "이전 레벨을 모두 풀어야만 다음 레벨을 선택할 수 있습니다.",
                grade: JLPTGrade.allCases[selectJlpt],
                maxLevel: viewModel.state.jlpt[selectJlpt].count - 1,
                action: {
                    viewModel.updateCurrentLearningList(viewModel.state.jlpt[selectJlpt][selectLevel])
                    coordinator.push(.learning)
                }
            )
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.resetTimer()
            viewModel.state.pendingResults.removeAll()
        }
        .onDisappear {
            // 화면을 벗어날 시 모든 설정 초기화
            selectJlpt = 0
            selectLevel = 0
            isShowingAlert = false
        }
    }
}

#Preview {
    LearningSelectView()
}
