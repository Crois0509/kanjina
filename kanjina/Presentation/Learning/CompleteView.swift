//
//  CompleteView.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import SwiftUI

struct CompleteView: View {
    
    @EnvironmentObject private var viewModel: KanjiViewModel
        
    private var successRate: String {
        let pendingResults = viewModel.state.pendingResults
        let totalCount = pendingResults.count
        guard totalCount > 0 else { return "0%" }
        let successCount = pendingResults.count(where: { $0.state == .success })
        guard successCount > 0 else { return "0%" }
        let result = (Double(successCount) / Double(totalCount)) * 100
        return result == 100 ? "100%" : String(format: "%.2f", result) + "%"
    }
    
    var onBackAction: () -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 20) {
                VStack(alignment: .center, spacing: 8) {
                    Text("🎉")
                        .font(.shoraiSans(size: 40, weight: .black))
                    
                    Text("학습 완료!")
                        .foregroundStyle(.white)
                        .font(.shoraiSans(size: 32, weight: .bold))
                }
                
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.white)
                        .opacity(0.4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.6), lineWidth: 1.0)
                        )
                    
                    VStack(alignment: .center, spacing: 30) {
                        VStack(alignment: .center, spacing: 8) {
                            Text("정답률")
                                .foregroundStyle(.white)
                                .font(.shoraiSans(size: 24, weight: .black))
                            
                            Text(successRate)
                                .foregroundStyle(.white)
                                .font(.shoraiSans(size: 36, weight: .black))
                        }
                        
                        HStack(alignment: .center, spacing: 32) {
                            let keys = QuestionState.allCases
                            ForEach(keys, id: \.self) { key in
                                VStack(alignment: .center, spacing: 8) {
                                    Text(key.title)
                                        .foregroundStyle(.white)
                                        .font(.shoraiSans(size: 20, weight: .demi))
                                    
                                    Text("\(viewModel.state.pendingResults.count(where: { $0.state == key }))개")
                                        .foregroundStyle(.white)
                                        .font(.shoraiSans(size: 24, weight: .medium))
                                }
                            }
                        }
                        
                        Rectangle()
                            .foregroundStyle(.white)
                            .frame(height: 1.0)
                            .padding(.horizontal, 20)
                        
                        VStack(alignment: .center, spacing: 8) {
                            Text("학습 시간")
                                .foregroundStyle(.white)
                                .font(.shoraiSans(size: 20, weight: .demi))
                            
                            Text(viewModel.state.learningTime.formatTime)
                                .foregroundStyle(.white)
                                .font(.shoraiSans(size: 24, weight: .medium))
                        }
                    }
                    .shadow(color: .black.opacity(0.2), radius: 2)
                }
                .frame(height: 400)
                                
                ActiveButton(title: "학습 완료하기") {
                    viewModel.finishLearning()
                    onBackAction()
                }
            }
        }
        .scrollIndicators(.hidden)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .padding(.top, 30)
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [
                    Color.N4.main,
                    Color.N4.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .onAppear {
            viewModel.pauseTimer()
        }
    }
}

fileprivate struct ActiveButton: View {
    
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
            
        } label: {
            Text(title)
                .foregroundStyle(.blue)
                .font(.shoraiSans(size: 20, weight: .bold))
                .padding(.vertical, 16)
                .padding(.horizontal, 34)
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.25), radius: 4)
    }
}
