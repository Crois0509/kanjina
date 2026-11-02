//
//  DailyStudy.swift
//  kanjina
//
//  Created by 장상경 on 5/16/26.
//

import Foundation

struct DailyStudy: Hashable {
    let date: Date
    var totalStudyMinutes: Int
    var correctCount: Int
    var incorrectCount: Int
}

extension DailyStudy {
    static var mockData: [Self] {
        let calendar = Calendar.current
        let today = Date()
        
        func date(offset: Int) -> Date {
            return calendar.date(byAdding: .day, value: offset, to: today) ?? Date()
        }
        
        return [
            // 7일 전: 무난한 시작
            DailyStudy(date: date(offset: -6), totalStudyMinutes: 450, correctCount: 60, incorrectCount: 15),
            
            // 6일 전: 살짝 바빠서 덜 함 (차트의 굴곡을 위해)
            DailyStudy(date: date(offset: -5), totalStudyMinutes: 300, correctCount: 40, incorrectCount: 10),
            
            // 5일 전: 다시 마음 다잡고 공부
            DailyStudy(date: date(offset: -4), totalStudyMinutes: 650, correctCount: 90, incorrectCount: 20),
            
            // 4일 전: 회식이나 야근으로 아주 조금만 (가장 낮은 막대)
            DailyStudy(date: date(offset: -3), totalStudyMinutes: 200, correctCount: 25, incorrectCount: 5),
            
            // 3일 전: 밀린 공부 시작 (상승 곡선)
            DailyStudy(date: date(offset: -2), totalStudyMinutes: 900, correctCount: 120, incorrectCount: 30),
            
            // 2일 전: 주말 폭풍 학습! (차트의 하이라이트, 가장 높은 막대)
            DailyStudy(date: date(offset: -1), totalStudyMinutes: 1200, correctCount: 160, incorrectCount: 40),
            
            // 오늘: 안정적인 유지
            DailyStudy(date: today, totalStudyMinutes: 85, correctCount: 110, incorrectCount: 25)
        ]
    }
}
