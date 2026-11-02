//
//  AppCoordinatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import CoreData

struct AppCoordinatorView: View {
    
    @StateObject private var appCoordinator: AppCoordinator
    @StateObject private var viewModel: KanjiViewModel
    
    @State private var isLaunchView: Bool = true
    
    private let diContainer: DIContainer
    
    init(appCoordinator: AppCoordinator, diContainer: DIContainer) {
        self._appCoordinator = StateObject(wrappedValue: appCoordinator)
        self._viewModel = StateObject(wrappedValue: diContainer.viewModel)
        self.diContainer = diContainer
    }
    
    var body: some View {
        ZStack {
            if isLaunchView {
                OnboardingView()
                    .transition(.opacity)
            } else {
                appCoordinator.build()
                    .environmentObject(viewModel)
            }
        }
        .animation(.easeInOut, value: isLaunchView)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.isLaunchView = false
            }
        }
        .task {
            await viewModel.fetchKanjiData()
            viewModel.fetchLearningList()
            viewModel.fetchStudySummary()
            viewModel.fetchBookmarkKanjiList()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: diContainer.coreDataManager.container.viewContext)) { notification in
            handleCoreDataSave(notification: notification)
        }
    }
    
    private func handleCoreDataSave(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let inserted = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
        let updated = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
        let deleted = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []
        let allChanges = inserted.union(updated).union(deleted)
        
        let didChangeLearningKanjiData = allChanges.contains { object in
            let entityName = object.entity.name
            return entityName == CoreDataConfig.kanji
        }
        
        let didChangeStudyData = allChanges.contains { object in
            let entityName = object.entity.name
            return entityName == CoreDataConfig.study
        }
        
        if didChangeLearningKanjiData {
            viewModel.fetchLearningList()
            viewModel.fetchBookmarkKanjiList()
            debugPrint("✅ 학습한 한자 리스트 불러오기 완료")
        }
        
        if didChangeStudyData {
            viewModel.fetchStudySummary()
            debugPrint("✅ 학습기록 리스트 불러오기 완료")
        }
    }
}
