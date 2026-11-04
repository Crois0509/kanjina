//
//  MainView.swift
//  kanjina
//
//  Created by 장상경 on 5/8/26.
//

import SwiftUI

// MARK: - Main View

struct MainView: View {
    
    @EnvironmentObject private var coordinator: MainCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    @Binding var selection: TabSelection // 현재 선택된 탭
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            TabView(selection: $selection) {
                // JLPT 단어 학습(메인)
                Tab(value: .learning) {
                    LearningCoordinatorView()
                        .environmentObject(coordinator.learningCoordinator)
                    
                } label: {
                    Image(systemName: "house")
                    Text("학습")
                }
                
                // 단어장 학습
                Tab(value: .vocabulary) {
                    VocabularyNoteCoordinatorView()
                        .environmentObject(coordinator.vocabularyNoteCoordinator)
                    
                } label: {
                    Image(systemName: "book")
                    Text("단어장")
                }
                
                // 마이페이지&설정
                Tab(value: .setting) {
                    MyPageCoordinatorView()
                        .environmentObject(coordinator.settingCoordinator)
                    
                } label: {
                    Image(systemName: "person.fill")
                    Text("내 정보")
                }
            }
            .environmentObject(viewModel)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .overlay(alignment: .top) {
            if viewModel.toastAlarm.isShowing {
                ToastView(message: viewModel.toastAlarm.message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 10)
                    .zIndex(1)
            }
        }
    }
}
