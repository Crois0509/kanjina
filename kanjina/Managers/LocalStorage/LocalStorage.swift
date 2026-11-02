//
//  LocalStorage.swift
//  kanjina
//
//  Created by 장상경 on 5/11/26.
//

import Foundation

enum LocalStorage {
    private static let defaults = UserDefaults.standard
    
    private static func lockKey(grade: JLPTGrade, level: Int) -> String {
        return "\(grade.rawValue)-\(level)"
    }
    
    private static func progressKey(grade: JLPTGrade, level: Int) -> String {
        return "\(grade.rawValue)-\(level)-progress"
    }
    
    static func saveLevelProgress(grade: JLPTGrade, level: Int, progress: Double) {
        let key = progressKey(grade: grade, level: level)
        let oldValue = defaults.double(forKey: key)
        
        if oldValue < progress {
            defaults.set(progress, forKey: key)
        }
    }
    
    static func unlockLevel(grade: JLPTGrade, level: Int) {
        defaults.set(false, forKey: lockKey(grade: grade, level: level))
    }
    
    static func loadLevelInfo(grade: JLPTGrade, level: Int) -> (isLocked: Bool, progress: Double) {
        let lockKeyStr = lockKey(grade: grade, level: level)
        let progressKeyStr = progressKey(grade: grade, level: level)
        
        let isLocked = defaults.object(forKey: lockKeyStr) as? Bool ?? (level != 1)
        let progress = defaults.double(forKey: progressKeyStr)
        
        return (isLocked, progress)
    }
    
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

