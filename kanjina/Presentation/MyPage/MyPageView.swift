//
//  MyPageView.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import SwiftUI

struct MyPageView: View {
    
    @EnvironmentObject private var coordinator: MyPageCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    @AppStorage(UserDefaultsConfig.resetTrigger) private var resetTrigger: String = ""
    @AppStorage(UserDefaultsConfig.timeLimit) private var timeLimit: Int = 5
    
    @State private var isShowingResetAlert: Bool = false
    @State private var isShowingMoreAlert: Bool = false
    
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    
    private var timeLimits: [Int] = [3, 5, 10, 15, 20]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("내 정보")
                .foregroundStyle(Color.black)
                .font(.shoraiSans(size: 32, weight: .bold))
                .padding(.bottom, 8)
                .padding(.horizontal, 20)
            
            Text("내 학습 현황과 설정을 관리하세요!")
                .foregroundStyle(Color.secondary)
                .font(.shoraiSans(size: 16, weight: .regular))
                .padding(.bottom, 8)
                .padding(.horizontal, 20)
            
            ScrollView {
                LazyVStack(alignment: .center, spacing: 16) {
                    // MARK: - 학습 현황
                    
                    HStack {
                        MyPageSection(title: "학습 현황", image: "chart.line.uptrend.xyaxis.circle.fill")
                        
                        Spacer()
                        
                        Button {
                            if viewModel.state.learningKanjiList.isEmpty {
                                isShowingMoreAlert = true
                                
                            } else {
                                coordinator.push(.situation)
                            }
                            
                        } label: {
                            Text("자세히 보기")
                                .font(.shoraiSans(size: 16, weight: .regular))
                                .foregroundStyle(.accent)
                        }
                    }
                    
                    if viewModel.state.learningKanjiList.isEmpty {
                        Text("아직 학습한 내역이 없습니다.")
                            .font(.shoraiSans(size: 20, weight: .medium))
                            .foregroundStyle(.gray)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.2), radius: 2)
                        
                    } else {
                        LearningSituationView(
                            learningKanjiList: viewModel.state.learningKanjiList
                        )
                    }
                    
                    // MARK: - 제한시간
                    
                    MyPageSection(title: "문제당 제한시간 설정", image: "clock.fill")
                    
                    VStack(spacing: 0) {
                        ForEach(timeLimits, id: \.self) { time in
                            Button {
                                timeLimit = time
                                
                            } label: {
                                HStack {
                                    Text("\(time)초")
                                        .font(.shoraiSans(size: 16, weight: .medium))
                                        .foregroundStyle(timeLimit == time ? .blue : .black)
                                    
                                    Spacer()
                                    
                                    if timeLimit == time {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14, weight: .bold))
                                            .padding(4)
                                            .background(.blue)
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 14)
                                .background(timeLimit == time ? .accent.opacity(0.1) : .white)
                                .overlay {
                                    Rectangle()
                                        .stroke(.gray.opacity(0.2), lineWidth: 0.5)
                                }
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 2)
                    
                    // MARK: - 데이터 관리
                    
                    MyPageSection(title: "데이터 관리", image: "server.rack")
                    
                    Button {
                        isShowingResetAlert = true
                        
                    } label: {
                        HStack {
                            Text("학습기록 초기화")
                                .font(.shoraiSans(size: 16, weight: .medium))
                                .foregroundStyle(.red)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 14)
                            
                            Spacer()
                        }
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.2), radius: 2)
                    
                    // MARK: - 앱 정보
                    
                    VStack(alignment: .center, spacing: 20) {
                        Image(.logo)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Text("칸지-나")
                            .font(.shoraiSans(size: 24, weight: .bold))
                            .foregroundStyle(.gray)
                        
                        Text("Version \(appVersion)")
                            .font(.shoraiSans(size: 16, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        Text("JLPT 공부도 칸지-나로 칸지나게")
                            .font(.shoraiSans(size: 16, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 20)
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 10)
        .toolbarVisibility(.hidden, for: .navigationBar)
        .alert("정말 초기화 하시겠습니까?", isPresented: $isShowingResetAlert) {
            Button("취소", role: .cancel) {
                isShowingResetAlert = false
            }
            
            Button("확인", role: .destructive) {
                viewModel.deleteAllData()
                resetTrigger = UUID().uuidString
            }
        } message: {
            Text("기록을 초기화 하면 다시 되돌릴 수 없습니다.")
        }
        .alert("학습 내용이 없습니다.", isPresented: $isShowingMoreAlert) {
            Button("확인", role: .cancel) {
                isShowingResetAlert = false
            }
        } message: {
            Text("단어를 학습하신 후 학습 현황을 확인하실 수 있습니다.")
        }
    }
}

#Preview {
    MyPageView()
}
