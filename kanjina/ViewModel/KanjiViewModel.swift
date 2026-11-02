//
//  KanjiViewModel.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

struct ViewModelState {
    var isLoading: Bool = false // 현재 로딩 상태
    var jlpt: [[KanjiList]] = [] // 전체 한자 리스트
    var numberOfKanjiByGrade: [Int] = [] // 급수별 한자 수
    
    var learningKanjiList: [(kanji: Kanji, isSuccessful: Bool)] = [] // 학습한 한자 리스트
    var dailyStudySummary: [DailyStudy] = [] // 학습한 시간 리스트
    var searchLearnedKanjiList: [(title: String, items: [(kanji: Kanji, isSuccessful: Bool)])] = [] // 검색한 학습 한자 리스트
    var searchVocaKanjiList: [(title: String, items: [Kanji])] = []
    
    var bookmarkKanjiList: [Kanji] = [] // 북마크한 한자 리스트
    var currentLearningKanjiList: KanjiList? = nil // 현재 학습 중인 한자 리스트
    var pendingResults: [KanjiLearningResult] = [] // 현재 답변을 완료한 한자 리스트
    var learningTime: Int = 0 // 현재 학습 시간
    var remainingTime: Int = 5 // 문제별 제한시간
}

struct ToastAlarm {
    var isShowing: Bool = false
    var message: String = ""
}

final class KanjiViewModel: ObservableObject {
    @Published var state = ViewModelState()
    @Published var toastAlarm = ToastAlarm()
    
    private let kanjiManager = KanjiDataManager()
    private let coreDataManager: CoreDataManager
    
    private var timer: Timer? = nil
    private var searchTask: Task<Void, Never>?
    private var cachedKanjisByGrade: [JLPTGrade: [Kanji]] = [:]
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
}

// MARK: - 데이터 CRUD 관련 Method

@MainActor
extension KanjiViewModel {
    /// 모든 한자 리스트를 불러오는 메서드
    func fetchKanjiData() async {
        do {
            let kanjiData = try kanjiManager.loadAllKanjiData()
            self.state.jlpt = kanjiData.map { $0.kanjiLists }
            self.state.numberOfKanjiByGrade = kanjiData.map { $0.totalKanjiCount }
            buildCache()
            
        } catch {
            debugPrint("🚨 알 수 없는 에러", error.localizedDescription)
        }
    }
    
    func buildCache() {
        for (index, levelLists) in state.jlpt.enumerated() {
            let grade = JLPTGrade.allCases[index]
            cachedKanjisByGrade[grade] = levelLists.flatMap { $0.kanjis }
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
    
    /// 현재 학습 중인 한자 리스트를 업데이트 하는 메서드
    /// - Parameter list: 업데이트할 한자 리스트
    func updateCurrentLearningList(_ list: KanjiList) {
        state.currentLearningKanjiList = list
    }
    
    /// 학습 정보를 초기화 하는 메서드
    func deleteAllData() {
        coreDataManager.removeAllData(entity: .kanji)
        coreDataManager.removeAllData(entity: .learningTime)
        LocalStorage.removeAllData()
    }
    
    func updateKanjiBookmarkState(_ kanji: Kanji, isBookmarked: Bool) {
        coreDataManager.updateBookmardKanji(kanji, isBookmark: isBookmarked)
    }
}

// MARK: - 단어 학습 관련 Method

extension KanjiViewModel {
    func checkAnswer(kanji: Kanji, isCorrect: QuestionState, isBookmark: Bool) {
        if let current = state.currentLearningKanjiList {
            let result = KanjiLearningResult(
                kanji: kanji,
                level: current.level,
                state: isCorrect,
                bookmark: isBookmark
            )
            
            if let index = state.pendingResults.firstIndex(where: { $0.kanji == result.kanji }) {
                state.pendingResults[index].state = isCorrect
                state.pendingResults[index].bookmark = isBookmark
                
            } else {
                state.pendingResults.append(result)
            }
            
        } else {
            let result = KanjiLearningResult(
                kanji: kanji,
                level: 99,
                state: isCorrect,
                bookmark: isBookmark
            )
            
            if let index = state.pendingResults.firstIndex(where: { $0.kanji == result.kanji }) {
                state.pendingResults[index].state = isCorrect
                state.pendingResults[index].bookmark = isBookmark
                
            } else {
                state.pendingResults.append(result)
            }
        }
    }
    
    func finishLearning() {
        let successCount = state.pendingResults.count(where: { $0.state == .success })
        
        if let kanjiList = state.currentLearningKanjiList,
           let grade = kanjiList.kanjis.first?.grade
        {
            coreDataManager.saveLearningRecord(grade: grade, level: kanjiList.level, results: state.pendingResults)
            
            let progress = Double(successCount) / Double(state.pendingResults.count)
            LocalStorage.saveLevelProgress(grade: grade, level: kanjiList.level, progress: progress)
            
            if progress >= 1.0,
               let gradeLevel = JLPTGrade.allCases.firstIndex(of: grade),
               (kanjiList.level + 1) <= state.jlpt[gradeLevel].count,
               LocalStorage.loadLevelInfo(grade: grade, level: kanjiList.level + 1).isLocked
            {
                LocalStorage.unlockLevel(grade: grade, level: kanjiList.level + 1)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showToastAlarm(message: "🎉 \(grade.rawValue)급의 레벨 \(kanjiList.level + 1) 이/가 해금되었습니다!! 🎉")
                }
            }
        }
        
        let dailyStudy = DailyStudy(
            date: Date(),
            totalStudyMinutes: state.learningTime,
            correctCount: successCount,
            incorrectCount: state.pendingResults.count - successCount
        )
        
        coreDataManager.saveLearningTime(dailyStudy)
        state.pendingResults.removeAll()
        state.currentLearningKanjiList = nil
        resetTimer()
    }
    
    func checkBookmarked(kanji: Kanji) -> Bool {
        return state.bookmarkKanjiList.contains(where: {
            $0.kanji == kanji.kanji
        })
    }
}

// MARK: - 학습 시간 관련 Method

extension KanjiViewModel {
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.state.learningTime += 1
            self?.state.remainingTime -= 1
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        state.learningTime = 0
        state.remainingTime = UserDefaults.standard.integer(forKey: UserDefaultsConfig.timeLimit)
    }
}

// MARK: - 단어장 관련 Method

extension KanjiViewModel {
    func updateLearnedSearch(for input: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(for: .seconds(0.3))
            if Task.isCancelled { return }
            
            let result = await performFilter(for: input)
            
            await MainActor.run {
                self.state.searchLearnedKanjiList = groupedLearnedList(result)
            }
        }
    }
    
    func updateVocaSearch(for input: String, segmentIndex: Int) {
        searchTask?.cancel()
        
        searchTask = Task {
            if !input.isEmpty {
                try? await Task.sleep(for: .seconds(0.3))
            }
            
            if Task.isCancelled { return }
            
            let result = await performFilter(for: input, segmentIndex: segmentIndex)
            
            await MainActor.run {
                self.state.searchVocaKanjiList = groupedList(result)
            }
        }
    }
    
    @MainActor
    func resetSearch() {
        searchTask?.cancel()
        state.searchLearnedKanjiList.removeAll()
        state.searchVocaKanjiList.removeAll()
    }
    
    private func performFilter(for input: String) async -> [(kanji: Kanji, isSuccessful: Bool)] {
        let query = input.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard !query.isEmpty else { return state.learningKanjiList }
        return state.learningKanjiList.filter {
            $0.kanji.searchKey.contains(query)
        }
    }
    
    private func performFilter(for input: String, segmentIndex: Int) async -> [Kanji] {
        let grade = JLPTGrade.allCases[segmentIndex]
        let targetList = cachedKanjisByGrade[grade] ?? []
        
        if input.isEmpty {
            return targetList
        }
        
        let query = input.trimmingCharacters(in: .whitespaces).lowercased()
        return targetList.filter { $0.searchKey.contains(query) }
    }
    
    func groupedList(_ list: [Kanji]) -> [(String, [Kanji])] {
        let dic = Dictionary(grouping: list, by: { getHiraganaRow(for: $0.hiragana) })
        return dic.map {
            (title: $0.key, $0.value.sorted { $0.hiragana < $1.hiragana })
        }
        .sorted(by: { $0.title < $1.title })
    }
    
    func groupedLearnedList(_ list: [(kanji: Kanji, Bool)]) -> [(String, [(Kanji, Bool)])] {
        let dic = Dictionary(grouping: list, by: { getHiraganaRow(for: $0.kanji.hiragana) })
        return dic.map { item in
            (title: item.key, item.value.sorted(by: { $0.kanji.hiragana < $1.kanji.hiragana }))
        }
        .sorted(by: { $0.title < $1.title })
    }
    
    private func getHiraganaRow(for string: String?) -> String {
        guard let first = string?.first else { return "기타" }
        let char = String(first)
        
        // 히라가나와 가타카나(탁음, 반탁음, 요음 포함)를 모두 각 행으로 매핑합니다.
        switch char {
        case _ where "あいうえおぁぃぅぇぉアイウエオァィゥェォヴ".contains(char):
            return "あ"
        case _ where "かきくけこがぎぐげごカキクケコガギグゲゴヵヶ".contains(char):
            return "か"
        case _ where "さしすせそざじずぜぞサシスセソザジズゼゾ".contains(char):
            return "さ"
        case _ where "たちつてとだぢづでどっタチツテトダヂヅデドッ".contains(char):
            return "た"
        case _ where "なにぬねのナニヌネノ".contains(char):
            return "な"
        case _ where "はひふへほばびぶべぼぱぴぷぺぽハヒフヘホバビブベボパピプペポ".contains(char):
            return "は"
        case _ where "まみむめもマミムメモ".contains(char):
            return "ま"
        case _ where "やゆよゃゅょヤユヨャュョ".contains(char):
            return "や"
        case _ where "らりるれろラリルレロ".contains(char):
            return "ら"
        case _ where "わをんワヲン".contains(char):
            return "わ"
        default:
            return "기타" // 한자, 영문, 숫자, 특수기호 등
        }
    }
}

// MARK: - ToastMessage 관련 Method

@MainActor
extension KanjiViewModel {
    func showToastAlarm(message: String) {
        toastAlarm.message = message
        
        withAnimation(.spring) {
            toastAlarm.isShowing = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring) {
                self.toastAlarm.isShowing = false
            }
        }
    }
}
