//
//  LearningSituationView.swift
//  kanjina
//
//  Created by 장상경 on 5/8/26.
//

import SwiftUI
import Charts

struct QuestionResult: Identifiable {
    let id = UUID()
    let type: String
    let count: Int
}

struct LearningSituationView: View {
    
    private let results: [QuestionResult]
    private let successCount: Int
    private let failCount: Int
    
    private var totalCount: Int {
        results.reduce(0) { $0 + $1.count }
    }
    
    init(learningKanjiList: [(Kanji, isSuccessful: Bool)]) {
        let successfulCount = learningKanjiList.count(where: { $0.isSuccessful })
        let failCount = learningKanjiList.count - successfulCount
        
        self.successCount = successfulCount
        self.failCount = failCount
        
        self.results = [
            QuestionResult(type: "isSuccessful", count: successfulCount),
            QuestionResult(type: "fail", count: failCount)
        ]
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Chart(results) { element in
                SectorMark(
                    angle: .value("Count", element.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .cornerRadius(8.0)
                .foregroundStyle(by: .value("Type", element.type))
            }
            .chartLegend(.hidden)
            .chartForegroundStyleScale([
                "isSuccessful": Color.blue.gradient,
                "fail": Color.red.opacity(0.8).gradient
            ])
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("학습한 단어")
                    .font(.shoraiSans(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
                
                Text("\(totalCount)개")
                    .font(.shoraiSans(size: 20, weight: .medium))
                    .foregroundStyle(.black)
                    .padding(.bottom, 10)
                
                LegendView(title: "알고 있음", count: successCount, color: .blue)
                LegendView(title: "모름", count: failCount, color: .red.opacity(0.8))
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 2)
    }
}
