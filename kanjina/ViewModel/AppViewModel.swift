//
//  AppViewModel.swift
//  kanjina
//
//  Created by 장상경 on 11/2/26.
//

import SwiftUI
import Combine
import CoreData

struct AppState: Hashable {
    var jlpt: [[KanjiList]] = [] // 전체 한자 리스트
    var numberOfKanjiByGrade: [Int] = [] // 급수별 한자 수
    var learningKanjiList: [LearningKanji] = [] // 학습한 한자 리스트
    var dailyStudySummary: [DailyStudy] = [] // 학습한 시간 리스트
    var bookmarkKanjiList: [Kanji] = [] // 북마크한 한자 리스트
    var cachedKanjisByGrade: [JLPTGrade: [Kanji]] = [:]
}

final class AppViewModel: ObservableObject {
    @Published var state = AppState()
    
    private let kanjiManager: KanjiDataManager
    private let coreDataManager: CoreDataManager
        
    init(
        kanjiManager: KanjiDataManager,
        coreDataManager: CoreDataManager
    ) {
        self.kanjiManager = kanjiManager
        self.coreDataManager = coreDataManager
    }
}

extension AppViewModel {
    /// 모든 한자 리스트를 불러오는 메서드
    func fetchKanjiData() async {
        do {
            let kanjiData = try kanjiManager.loadAllKanjiData()
            state.jlpt = kanjiData.map { $0.kanjiLists }
            state.numberOfKanjiByGrade = kanjiData.map { $0.totalKanjiCount }
            buildCacheForKanjiList()
            
        } catch {
            debugPrint("🚨 알 수 없는 에러", error.localizedDescription)
        }
    }
    
    func buildCacheForKanjiList() {
        for (index, levelLists) in state.jlpt.enumerated() {
            let grade = JLPTGrade.allCases[index]
            state.cachedKanjisByGrade[grade] = levelLists.flatMap { $0.kanjis }
        }
    }
    
    /// 학습한 한자 목록을 불러오는 메서드
    func fetchLearningList() {
        state.learningKanjiList = coreDataManager.fetchAllRecords()
    }
    
    /// 학습한 날짜와 시간을 불러오는 메서드
    func fetchStudySummary() {
        state.dailyStudySummary = coreDataManager.fetchLearningWeeklyTimeList()
    }
    
    func fetchBookmarkKanjiList() {
        state.bookmarkKanjiList = coreDataManager.fetchBookmarkKanjis().removingDuplicates()
    }
    
    /// CoreData에 데이터를 저장하는 메서드
    /// - Parameter notification: 데이터를 저장할 CoreData의 Publisher 이벤트
    func handleCoreDataSave(notification: Notification) {
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
            fetchLearningList()
            fetchBookmarkKanjiList()
            debugPrint("✅ 학습한 한자 리스트 불러오기 완료")
        }
        
        if didChangeStudyData {
            fetchStudySummary()
            debugPrint("✅ 학습기록 리스트 불러오기 완료")
        }
    }
}

