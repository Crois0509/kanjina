//
//  AppCoordinatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import CoreData

// MARK: - AppCoordinator View

struct AppCoordinatorView: View {
    
    @StateObject private var appCoordinator: AppCoordinator
    @StateObject private var appViewModel: AppViewModel
    @StateObject private var kanjiViewModel: KanjiViewModel
    
    @State private var isLaunchView: Bool = true
    
    private let diContainer: DIContainer
    
    init(appCoordinator: AppCoordinator, diContainer: DIContainer) {
        self._appCoordinator = StateObject(wrappedValue: appCoordinator)
        self._appViewModel = StateObject(wrappedValue: diContainer.appViewModel)
        self._kanjiViewModel = StateObject(wrappedValue: diContainer.kanjiViewModel)
        self.diContainer = diContainer
    }
    
    var body: some View {
        ZStack {
            if isLaunchView {
                LaunchView()
                    .transition(.opacity)
            } else {
                appCoordinator.build()
                    .environmentObject(kanjiViewModel)
            }
        }
        .animation(.easeInOut, value: isLaunchView)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isLaunchView = false
            }
        }
        .task {
            await appViewModel.fetchKanjiData()
            appViewModel.fetchLearningList()
            appViewModel.fetchStudySummary()
            appViewModel.fetchBookmarkKanjiList()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: diContainer.coreDataManager.container.viewContext)) { notification in
            appViewModel.handleCoreDataSave(notification: notification)
        }
        .onChange(of: appViewModel.state) { _, state in
            kanjiViewModel.updateState(
                jlpt: state.jlpt,
                numberOfKanjiByGrade: state.numberOfKanjiByGrade,
                learningKanjiList: state.learningKanjiList,
                dailyStudySummary: state.dailyStudySummary,
                bookmarkKanjiList: state.bookmarkKanjiList,
                cachedKanjisByGrade: state.cachedKanjisByGrade
            )
        }
    }
}
