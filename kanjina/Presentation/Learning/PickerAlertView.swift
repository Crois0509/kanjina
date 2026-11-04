//
//  CommontAlertView.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import SwiftUI

// MARK: - PickerAlert View

/// JLPT 레벨을 선택하는 Alert UI
struct PickerAlertView: View {
    
    @Binding var isShowing: Bool
    @Binding var selection: Int
    
    let title: String
    let content: String
    let grade: JLPTGrade
    let maxLevel: Int
    let action: () -> Void // 확인 버튼 선택 시 액션
    
    var body: some View {
        ZStack(alignment: .center) {
            if isShowing {
                Rectangle()
                    .onTapGesture {
                        selection = 0
                        isShowing = false
                    }
                    .foregroundStyle(.black)
                    .opacity(0.3)
                
                VStack(alignment: .leading, spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .foregroundStyle(.black)
                            .font(.shoraiSans(size: 16, weight: .bold))
                        
                        Text(content)
                            .foregroundStyle(.secondary)
                            .font(.shoraiSans(size: 14, weight: .regular))
                    }
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach((0...maxLevel), id: \.self) { index in
                                let levelInfo = LocalStorage.loadLevelInfo(grade: grade, level: index + 1)
                                
                                Button {
                                    selection = index
                                    
                                } label: {
                                    HStack {
                                        Text("Level \(index + 1)")
                                            .font(index == selection ? .shoraiSans(size: 14, weight: .bold) : .shoraiSans(size: 14, weight: .regular))
                                            .foregroundStyle(levelInfo.isLocked == true ? Color.gray : index == selection ? Color.white : Color.black)
                                        
                                        Spacer()
                                        
                                        if levelInfo.isLocked {
                                            Image(systemName: "lock.fill")
                                                .font(.shoraiSans(size: 14, weight: .regular))
                                                .foregroundStyle(Color.gray)
                                            
                                        } else {
                                            Text("\(String(format: "%.2f", levelInfo.progress * 100))%")
                                                .font(index == selection ? .shoraiSans(size: 14, weight: .bold) : .shoraiSans(size: 14, weight: .regular))
                                                .foregroundStyle(index == selection ? .white : .green)
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .background(levelInfo.isLocked ? Color.gray.opacity(0.3) : index == selection ? Color.accentColor : Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(SmoothAnimationButtonStyle())
                                .disabled(levelInfo.isLocked)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: 200)
                    
                    Divider()
                    
                    HStack(alignment: .center, spacing: 10) {
                        AlertButton(title: "취소", destructive: false) {
                            selection = 0
                            isShowing = false
                        }
                        
                        AlertButton(title: "확인", destructive: true) {
                            action()
                            isShowing = false
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .frame(maxWidth: 280)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isShowing)
        .ignoresSafeArea()
    }
}

// MARK: - PickerAlert View Private UI

fileprivate struct AlertButton: View {
    
    var title: String
    var destructive: Bool
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .foregroundStyle(destructive ? .blue : .black)
                .font(.shoraiSans(size: 16, weight: .medium))
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.gray.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(SmoothAnimationButtonStyle())
    }
}
