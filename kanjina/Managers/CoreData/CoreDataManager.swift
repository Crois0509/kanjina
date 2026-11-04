//
//  KanjiPersistenceController.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import Foundation
import CoreData

enum EntityType: String {
    case kanji = "KanjiEntity"
    case learningTime = "DailyStudySummary"
}

protocol CoreDataManagable {
    func saveLearningRecord(grade: JLPTGrade, level: Int, results: [KanjiLearningResult])
    func saveLearningTime(_ study: DailyStudy)
    func updateBookmarkedKanji(_ item: Kanji, isBookmark: Bool)
    
    func fetchAllRecords() -> [LearningKanji]
    func fetchLearningTimeList() -> [DailyStudy]
    func fetchLearningWeeklyTimeList() -> [DailyStudy]
    func fetchBookmarkKanjis() -> [Kanji]
    
    func removeAllData(entity: EntityType)
}

protocol CoreDataCRUDProtocol {
    func saveLearningRecord(grade: JLPTGrade, level: Int, results: [KanjiLearningResult])
    func saveLearningTime(_ study: DailyStudy)
    func updateBookmarkedKanji(_ item: Kanji, isBookmark: Bool)
    func removeAllData(entity: EntityType)
}

// MARK: - CoreData Manager

struct CoreDataManager: CoreDataManagable {
    let container: NSPersistentContainer
    
    init() {
        container = .init(name: CoreDataConfig.kanjiContainer)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("🚨 CoreData 로드 실패: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

// MARK: - CoreData Create Method

extension CoreDataManager {
    
    /// 학습 결과를 저장하는 메서드
    /// - Parameters:
    ///   - grade: JLPT 급수
    ///   - level: 급수별 레벨
    ///   - results: 학습 결과
    func saveLearningRecord(grade: JLPTGrade, level: Int, results: [KanjiLearningResult]) {
        guard !results.isEmpty else { return }
        let context = container.viewContext
        
        let fetchRequest: NSFetchRequest<KanjiEntity> = KanjiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "grade == %@ AND level == %d", grade.rawValue, level)
        
        do {
            let existingEntities = try context.fetch(fetchRequest)
            
            var existingDict: [String: KanjiEntity] = [:]
            for entity in existingEntities {
                if let kanji = entity.kanji {
                    existingDict[kanji] = entity
                }
            }
            
            for result in results {
                let kanjiString = result.kanji.kanji
                
                if let existingEntity = existingDict[kanjiString] {
                    existingEntity.learningDate = Date()
                    existingEntity.successful = result.state == .success
                    existingEntity.bookmark = result.bookmark
                    
                } else {
                    let newEntity = KanjiEntity(context: context)
                    newEntity.kanji = result.kanji.kanji
                    newEntity.hiragana = result.kanji.hiragana
                    newEntity.meaningEn = result.kanji.meaningEn
                    newEntity.meaningKo = result.kanji.meaningKo
                    newEntity.grade = result.kanji.grade.rawValue
                    newEntity.level = Int16(result.level)
                    newEntity.successful = result.state.isSuccessful
                    newEntity.learningDate = Date()
                    newEntity.bookmark = result.bookmark
                }
            }
            
            if context.hasChanges {
                try context.save()
                debugPrint("✅ 한자 목록 \(results.count)개 업데이트 성공")
            }
            
        } catch {
            debugPrint("❌ 한자 목록 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    /// 학습 시간을 저장하는 메서드
    /// - Parameter study: 학습 결과
    func saveLearningTime(_ study: DailyStudy) {
        let context = container.viewContext
        let request: NSFetchRequest<DailyStudySummary> = DailyStudySummary.fetchRequest()
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        request.predicate = NSPredicate(format: "date >= %@", startOfDay as NSDate)
        
        do {
            let results = try context.fetch(request)
            
            if results.isEmpty {
                let newEntity = DailyStudySummary(context: context)
                newEntity.date = study.date
                newEntity.totalStudyMinutes = Double(study.totalStudyMinutes)
                
            } else if let result = results.first {
                result.totalStudyMinutes += Double(study.totalStudyMinutes)
            }
            
            if context.hasChanges {
                try context.save()
                debugPrint("✅ 학습 시간 저장 성공")
            }
            
        } catch {
            debugPrint("❌ 학습 저장 실패: \(error.localizedDescription)")
        }
    }
    
    /// 북마크한 한자를 업데이트 하는 메서드
    /// - Parameters:
    ///   - item: 업데이트할 한자
    ///   - isBookmark: 북마크 여부
    func updateBookmarkedKanji(_ item: Kanji, isBookmark: Bool) {
        let context = container.viewContext
        let fetchRequest = KanjiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bookmark == true")
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let result = results.first(where: { $0.kanji == item.kanji }) {
                result.bookmark = isBookmark
            } else {
                let newEntity = KanjiEntity(context: context)
                newEntity.kanji = item.kanji
                newEntity.hiragana = item.hiragana
                newEntity.meaningEn = item.meaningEn
                newEntity.meaningKo = item.meaningKo
                newEntity.grade = item.grade.rawValue
                newEntity.bookmark = isBookmark
            }
            
            if context.hasChanges {
                try context.save()
                debugPrint("✅ \(item.kanji) 북마크 상태 업데이트 성공")
            }
            
        } catch {
            debugPrint("❌ 북마크 상태 업데이트 실패: \(error.localizedDescription)")
        }
    }
}

// MARK: - CoreData Read Method

extension CoreDataManager {
    
    /// 모든 학습 내용을 불러오는 메서드
    /// - Returns: 저장된 모든 학습 내용
    func fetchAllRecords() -> [LearningKanji] {
        let request: NSFetchRequest<KanjiEntity> = KanjiEntity.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(keyPath: \KanjiEntity.learningDate, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try container.viewContext.fetch(request)
            return results.compactMap { result in
                guard let kanji = result.kanji,
                      let hiragana = result.hiragana,
                      let meaningEn = result.meaningEn,
                      let meaningKo = result.meaningKo,
                      let gradeString = result.grade,
                      let grade = JLPTGrade(rawValue: gradeString)
                else {
                    return nil
                }
                
                let learningKanji = Kanji(
                    kanji: kanji,
                    hiragana: hiragana,
                    meaningEn: meaningEn,
                    meaningKo: meaningKo,
                    grade: grade
                )
                
                return LearningKanji(
                    kanji: learningKanji,
                    isSuccessful: result.successful
                )
            }
            
        } catch {
            debugPrint("🚨 데이터 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    /// 학습 시간 등의 학습 현황을 불러오는 메서드
    /// - Returns: 저장된 학습 현황
    func fetchLearningTimeList() -> [DailyStudy] {
        let request = DailyStudySummary.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(keyPath: \DailyStudySummary.date, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try container.viewContext.fetch(request)
            return results.compactMap {
                guard let date = $0.date else { return nil }
                
                return DailyStudy(
                    date: date,
                    totalStudyMinutes: Int($0.totalStudyMinutes),
                    correctCount: Int($0.correctCount),
                    incorrectCount: Int($0.incorrectCount)
                )
            }
            
        } catch {
            debugPrint("🚨 데이터 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    /// 주간 학습 현황을 불러오는 메서드
    /// - Returns: 저장된 주간 학습 현황
    func fetchLearningWeeklyTimeList() -> [DailyStudy] {
        let request = DailyStudySummary.fetchRequest()
        
        let calendar = Calendar.current
        let today = Date()
        let startOfToday = calendar.startOfDay(for: today)
        
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: startOfToday) else {
            return []
        }
        
        request.predicate = NSPredicate(format: "date >= %@", startDate as NSDate)
        
        let sortDescriptor = NSSortDescriptor(keyPath: \DailyStudySummary.date, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try container.viewContext.fetch(request)
            return results.compactMap {
                guard let date = $0.date else { return nil }
                
                return DailyStudy(
                    date: date,
                    totalStudyMinutes: Int($0.totalStudyMinutes),
                    correctCount: Int($0.correctCount),
                    incorrectCount: Int($0.incorrectCount)
                )
            }
            
        } catch {
            debugPrint("🚨 데이터 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    /// 북마크된 한자 목록을 불러오는 메서드
    /// - Returns: 북마크된 한자 목록
    func fetchBookmarkKanjis() -> [Kanji] {
        let fetchRequest = KanjiEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "bookmark == true")
        
        let sortDescriptor = NSSortDescriptor(keyPath: \KanjiEntity.kanji, ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let results = try container.viewContext.fetch(fetchRequest)
            debugPrint("✅ 북마크 데이터 \(results.count)개 불러오기 성공")
            
            return results.compactMap {
                guard let kanji = $0.kanji,
                      let hiragana = $0.hiragana,
                      let meaningEn = $0.meaningEn,
                      let meaningKo = $0.meaningKo,
                      let grade = JLPTGrade(rawValue: $0.grade ?? "")
                else { return nil }
                
                return Kanji(
                    kanji: kanji,
                    hiragana: hiragana,
                    meaningEn: meaningEn,
                    meaningKo: meaningKo,
                    grade: grade
                )
            }
            
        } catch {
            debugPrint("🚨 북마크 데이터 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - CoreData Delete Method

extension CoreDataManager {
    
    /// CoreData에 저장된 지정 Entity의 모든 데이터를 삭제하는 메서드
    /// - Parameter entity: 삭제할 Entity 타입
    func removeAllData(entity: EntityType) {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            context.reset()
            debugPrint("✅ \(entity.rawValue)의 모든 데이터가 삭제되었습니다.")
            
        } catch {
            debugPrint("🚨 \(entity.rawValue) 데이터 삭제 실패: \(error.localizedDescription)")
        }
    }
}
