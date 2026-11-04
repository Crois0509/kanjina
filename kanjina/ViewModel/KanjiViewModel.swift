//
//  KanjiViewModel.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine
import CoreData

/// KanjiViewModel이 관리할 Status
struct ViewModelState {
    var isLoading: Bool = false // 현재 로딩 상태
    var jlpt: [[KanjiList]] = [] // 전체 한자 리스트
    var numberOfKanjiByGrade: [Int] = [] // 급수별 한자 수
    var cachedKanjisByGrade: [JLPTGrade: [Kanji]] = [:] // 최적화된 급수별 한자 목록
    
    var learningKanjiList: [LearningKanji] = [] // 학습한 한자 리스트
    var dailyStudySummary: [DailyStudy] = [] // 학습한 시간 리스트
    var searchLearnedKanjiList: [(title: String, items: [LearningKanji])] = [] // 검색한 학습 한자 리스트
    var searchVocaKanjiList: [(title: String, items: [Kanji])] = [] // 검색한 한자 리스트
    
    var bookmarkKanjiList: [Kanji] = [] // 북마크한 한자 리스트
    var currentLearningKanjiList: KanjiList? = nil // 현재 학습 중인 한자 리스트
    var pendingResults: [KanjiLearningResult] = [] // 현재 답변을 완료한 한자 리스트
    var learningTime: Int = 0 // 현재 학습 시간
    var remainingTime: Int = 5 // 문제별 제한시간
}

/// Toast Message를 표시할 때 사용할 파라미터 객체
struct ToastAlarm {
    var isShowing: Bool = false
    var message: String = ""
}

// MARK: - KanjiViewModel

final class KanjiViewModel: ObservableObject {
    @Published var state = ViewModelState()
    @Published var toastAlarm = ToastAlarm()
    
    private let coreDataManager: CoreDataManager // 로컬 데이터 저장 관리 객체
    
    private var timer: Timer? = nil
    private var searchTask: Task<Void, Never>? // 검색 부하 방지용 테스크
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
}

// MARK: - 데이터 CRUD 관련 Method

@MainActor
extension KanjiViewModel {
    
    /// KanjiViewModel의 주요 State를 업데이트 하는 메서드
    func updateState(
        jlpt: [[KanjiList]],
        numberOfKanjiByGrade: [Int],
        learningKanjiList: [LearningKanji],
        dailyStudySummary: [DailyStudy],
        bookmarkKanjiList: [Kanji],
        cachedKanjisByGrade: [JLPTGrade: [Kanji]]
    ) {
        self.state.jlpt = jlpt
        self.state.numberOfKanjiByGrade = numberOfKanjiByGrade
        self.state.learningKanjiList = learningKanjiList
        self.state.dailyStudySummary = dailyStudySummary
        self.state.bookmarkKanjiList = bookmarkKanjiList
        self.state.cachedKanjisByGrade = cachedKanjisByGrade
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
    
    /// 한자의 북마크 상태를 업데이트 하는 메서드
    /// - Parameters:
    ///   - kanji: 한자 정보
    ///   - isBookmarked: 북마크 여부
    func updateKanjiBookmarkState(_ kanji: Kanji, isBookmarked: Bool) {
        coreDataManager.updateBookmarkedKanji(kanji, isBookmark: isBookmarked)
    }
}

// MARK: - 단어 학습 관련 Method

extension KanjiViewModel {
    
    /// 학습 한자의 정답 여부를 판단하고 현재 학습 목록을 업데이트 하는 메서드
    /// - Parameters:
    ///   - kanji: 한자 정보
    ///   - isCorrect: 정답 여부
    ///   - isBookmark: 북마크 여부
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
    
    /// 학습이 끝나면 로컬 저장소에 학습 정보를 저장하는 메서드
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
    
    /// 한자의 북마크 여부를 확인하는 메서드
    /// - Parameter kanji: 한자 정보
    /// - Returns: 북마크 여부
    func checkBookmarked(kanji: Kanji) -> Bool {
        return state.bookmarkKanjiList.contains(where: {
            $0.kanji == kanji.kanji
        })
    }
}

// MARK: - 학습 시간 관련 Method

extension KanjiViewModel {
    
    /// 타이머를 작동시키는 메서드
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.state.learningTime += 1
            self?.state.remainingTime -= 1
        }
    }
    
    /// 타이머를 정지 시키는 메서드
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 타이머를 초기화 시키는 메서드
    func resetTimer() {
        timer?.invalidate()
        timer = nil
        state.learningTime = 0
        state.remainingTime = UserDefaults.standard.integer(forKey: UserDefaultsConfig.timeLimit)
    }
}

// MARK: - 단어장 관련 Method

extension KanjiViewModel {
    
    /// 학습한 한자 단어장의 검색 결과를 업데이트 시키는 메서드
    /// - Parameter input: 검색어
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
    
    /// 모든 단어장의 검색 결과를 업데이트 시키는 메서드
    /// - Parameters:
    ///   - input: 검색어
    ///   - segmentIndex: 현재 선택된 JLPT 급수(Index)
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
    
    /// 검색 결과를 초기화하는 메서드
    @MainActor
    func resetSearch() {
        searchTask?.cancel()
        state.searchLearnedKanjiList.removeAll()
        state.searchVocaKanjiList.removeAll()
    }
    
    /// 검색어에 따라 학습한 한자의 필터링을 실행하는 메서드
    /// - Parameter input: 검색어
    /// - Returns: 필터링된 학습 한자 목록
    private func performFilter(for input: String) async -> [LearningKanji] {
        let query = input.trimmingCharacters(in: .whitespaces).lowercased()
        
        guard !query.isEmpty else { return state.learningKanjiList }
        return state.learningKanjiList.filter {
            $0.kanji.searchKey.contains(query)
        }
    }
    
    /// 검색어에 따라 모든 한자의 필터링을 실행하는 메서드
    /// - Parameters:
    ///   - input: 검색어
    ///   - segmentIndex: JLPT 급수(Index)
    /// - Returns: 필터링된 한자 목록
    private func performFilter(for input: String, segmentIndex: Int) async -> [Kanji] {
        let grade = JLPTGrade.allCases[segmentIndex]
        let targetList = state.cachedKanjisByGrade[grade] ?? []
        
        if input.isEmpty {
            return targetList
        }
        
        let query = input.trimmingCharacters(in: .whitespaces).lowercased()
        return targetList.filter { $0.searchKey.contains(query) }
    }
    
    /// 한자 목록을 히라가나 행에 맞춰 그룹화 해주는 메서드
    /// - Parameter list: 한자 목록
    /// - Returns: 그룹화된 한자 목록 => [(String, [Kanji])]
    func groupedList(_ list: [Kanji]) -> [(String, [Kanji])] {
        let dic = Dictionary(grouping: list, by: { getHiraganaRow(for: $0.hiragana) })
        return dic.map {
            (title: $0.key, $0.value.sorted { $0.hiragana < $1.hiragana })
        }
        .sorted(by: { $0.title < $1.title })
    }
    
    /// 한자 목록을 히라가나 행에 맞춰 그룹화 해주는 메서드
    /// - Parameter list: 학습한 한자 목록
    /// - Returns: 그룹화된 학습 한자 목록 => [(String, [LearningKanji])]
    func groupedLearnedList(_ list: [LearningKanji]) -> [(String, [LearningKanji])] {
        let dic = Dictionary(grouping: list, by: { getHiraganaRow(for: $0.kanji.hiragana) })
        return dic.map { item in
            (title: item.key, item.value.sorted(by: { $0.kanji.hiragana < $1.kanji.hiragana }))
        }
        .sorted(by: { $0.title < $1.title })
    }
    
    /// 주입된 단어의 히라가나 행을 구분하는 메서드
    /// - Parameter string: 일본어 단어(String)
    /// - Returns: 히라가나 행(String)
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
    /// Toast Message UI를 표시하는 메서드
    /// - Parameter message: 표시할 메세지
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
