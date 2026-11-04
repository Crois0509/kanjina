//
//  LocalStorage.swift
//  kanjina
//
//  Created by 장상경 on 5/11/26.
//

import Foundation

// MARK: - LocalStorage

// UserDefaults의 사용 편의성을 위해 만든 Storage

enum LocalStorage {
    private static let defaults = UserDefaults.standard
    
    private static func lockKey(grade: JLPTGrade, level: Int) -> String {
        return "\(grade.rawValue)-\(level)"
    }
    
    private static func progressKey(grade: JLPTGrade, level: Int) -> String {
        return "\(grade.rawValue)-\(level)-progress"
    }
    
    /// 레벨별 진행도를 저장하는 메서드
    /// - Parameters:
    ///   - grade: JLPT 급수
    ///   - level: 급수의 레벨
    ///   - progress: 진행도(%)
    static func saveLevelProgress(grade: JLPTGrade, level: Int, progress: Double) {
        let key = progressKey(grade: grade, level: level)
        let oldValue = defaults.double(forKey: key)
        
        if oldValue < progress {
            defaults.set(progress, forKey: key)
        }
    }
    
    /// 잠겨 있는 레벨의 상태를 변경하는 메서드
    /// - Parameters:
    ///   - grade: JLPT 급수
    ///   - level: 급수별 레벨
    static func unlockLevel(grade: JLPTGrade, level: Int) {
        defaults.set(false, forKey: lockKey(grade: grade, level: level))
    }
    
    /// 지정한 급수의 레벨의 상태 및 정보를 불러오는 메서드
    /// - Parameters:
    ///   - grade: JLPT 급수
    ///   - level: 급수별 레벨
    /// - Returns: 해당 레벨의 잠김 여부 + 진행도
    static func loadLevelInfo(grade: JLPTGrade, level: Int) -> (isLocked: Bool, progress: Double) {
        let lockKeyStr = lockKey(grade: grade, level: level)
        let progressKeyStr = progressKey(grade: grade, level: level)
        
        let isLocked = defaults.object(forKey: lockKeyStr) as? Bool ?? (level != 1)
        let progress = defaults.double(forKey: progressKeyStr)
        
        return (isLocked, progress)
    }
    
    /// UserDefaults에 저장된 모든 데이터를 초기화 하는 메서드
    static func removeAllData() {
        if let bundleId = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleId)
            defaults.synchronize()
            debugPrint("✅ UserDefaults 전체 초기화 완료")
        } else {
            debugPrint("🚨 UserDefaults를 초기화할 수 없습니다")
        }
    }
}

