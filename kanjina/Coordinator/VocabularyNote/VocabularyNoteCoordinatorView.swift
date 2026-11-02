//
//  VocabularyNoteCoordinatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

struct VocabularyNoteCoordinatorView: View {
    
    @EnvironmentObject private var coordinator: VocabularyNoteCoordinator
    @EnvironmentObject private var kanjiViewModel: KanjiViewModel
    @StateObject private var toolbarState = ToolBarState()
    @StateObject private var sheetState = SheetState()
    
    var body: some View {
        NavigationStack(path: coordinator.path) {
            VStack {
                coordinator.build(.home)
                    .navigationDestination(for: VocabularyNoteRoute.self) { route in
                        coordinator.build(route)
                            .environmentObject(sheetState)
                            .navigationBarBackButtonHidden(true)
                            .toolbar {
                                if route != .bookmarkLearning {
                                    CommonToolbar() {
                                        coordinator.pop()
                                    }
                                }
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                    if toolbarState.isRightButtonVisible {
                                        Button {
                                            if toolbarState.requiresAlert {
                                                toolbarState.showAlert = true
                                            } else {
                                                toolbarState.rightButtonAction?()
                                            }
                                            
                                        } label: {
                                            Image(systemName: toolbarState.rightButtonIcon)
                                        }
                                    }
                                }
                            }
                            .sheet(isPresented: $sheetState.isShowSheet) {
                                if let kanji = sheetState.kanji {
                                    KanjiDetailView(
                                        kanji: kanji,
                                        isSuccessful: sheetState.isSuccessful,
                                        isBookmarked: sheetState.isBookmarked
                                    )
                                    .presentationDetents([.medium, .large])
                                    .presentationDragIndicator(.visible)
                                }
                            }
                            .alert(toolbarState.alertTitle, isPresented: $toolbarState.showAlert) {
                                if toolbarState.rightButtonAction != nil {
                                    Button("취소", role: .cancel) { toolbarState.showAlert = false }
                                    Button("확인") { toolbarState.rightButtonAction?() }
                                } else {
                                    Button("확인", role: .cancel) { toolbarState.showAlert = false }
                                }
                            } message: {
                                Text(toolbarState.alertMessage)
                            }
                    }
                
                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard)
        .environmentObject(coordinator)
        .environmentObject(kanjiViewModel)
        .environmentObject(toolbarState)
    }
}
