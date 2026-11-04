//
//  KanjiDataManager.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import Foundation

// MARK: - KanjiDataManager

final class KanjiDataManager {
    
    /// 앱에 등록된 모든 한자를 불러와 변환하는 메서드
    /// - Returns: 급수별 한자 목록 + 급수별 한자 수의 배열
    func loadAllKanjiData() throws(KanjiError) -> [(kanjiLists: [KanjiList], totalKanjiCount: Int)] {
        let grades = JLPTGrade.allCases
        var kanjiLists = [([KanjiList], Int)]()
        
        for grade in grades {
            do {
                let kanjis = try loadKanjiData(for: grade).removingDuplicates()
                let sortedKanjis = kanjis.sorted(by: {
                    return $0.hiragana.count < $1.hiragana.count
                })
                
                let kanjiList = groupedForLevel(sortedKanjis)
                kanjiLists.append((kanjiList, kanjis.count))
                
            } catch {
                debugPrint(error.localizedDescription)
                return []
            }
        }
        
        return kanjiLists
    }
}

// MARK: - KanjiDataManager Private Method

private extension KanjiDataManager {
    
    /// 급수별 한자 데이터를 변환하는 메서드
    /// - Parameter grade: 불러올 급수
    /// - Returns: 급수별 한자 목록
    func loadKanjiData(for grade: JLPTGrade) throws(KanjiError) -> [Kanji] {
        guard let url = Bundle.main.url(forResource: "jlpt_\(grade.rawValue)", withExtension: "json") else {
            throw .fileNotFound
        }
        
        guard let data = try? Data(contentsOf: url) else {
            throw .dataConversionFail
        }
        
        do {
            let decoder = JSONDecoder()
            let decodeData = try decoder.decode([Kanji].self, from: data)
            return decodeData
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("🔑 키를 찾을 수 없음: '\(key.stringValue)' - \(context.debugDescription)")
            throw .decodingFail
            
        } catch let DecodingError.valueNotFound(value, context) {
            print("텅 빈 값(null) 발견: '\(value)' - \(context.debugDescription)")
            throw .decodingFail
            
        } catch let DecodingError.typeMismatch(type, context) {
            print("타입 불일치: '\(type)' - \(context.debugDescription)")
            throw .decodingFail
            
        } catch let DecodingError.dataCorrupted(context) {
            print("데이터 손상 또는 JSON 포맷 에러: \(context.debugDescription)")
            throw .decodingFail
            
        } catch {
            print("기타 에러: \(error.localizedDescription)")
            throw .decodingFail
        }
    }
    
    /// 한자 목록을 레벨로 분류해주는 메서드
    /// - Parameter items: 분류한 한자 목록
    /// - Returns: 레벨별로 분류된 한자 목록
    func groupedForLevel(_ items: [Kanji]) -> [KanjiList] {
        guard !items.isEmpty else { return [] }
        
        var result: [KanjiList] = []
        var level = 1
        let chunkSize = 50
        
        for start in stride(from: 0, to: items.count, by: chunkSize) {
            let end = min(start + chunkSize, items.count)
            let chunkedItems = Array(items[start..<end])
            
            let list = KanjiList(
                level: level,
                kanjis: chunkedItems
            )
            
            result.append(list)
            level += 1
        }
        
        return result
    }
}
