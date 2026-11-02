//
//  KanjiPersistenceController.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import Foundation
import CoreData

struct CoreDataManager {
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
    
    func updateBookmardKanji(_ item: Kanji, isBookmark: Bool) {
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
    
    func fetchAllRecords() -> [(Kanji, Bool)] {
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
                
                return (
                    Kanji(
                        kanji: kanji,
                        hiragana: hiragana,
                        meaningEn: meaningEn,
                        meaningKo: meaningKo,
                        grade: grade
                    ),
                    result.successful
                )
            }
            
        } catch {
            debugPrint("🚨 데이터 불러오기 실패: \(error.localizedDescription)")
            return []
        }
    }
    
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
    enum EntityType: String {
        case kanji = "KanjiEntity"
        case learningTime = "DailyStudySummary"
    }
    
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
