//
//  LearningSituationDetailView.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import SwiftUI
import Charts

struct LearningSituationDetailView: View {
    
    @EnvironmentObject private var coordinator: VocabularyNoteCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 12) {
                MyPageSection(title: "전체 학습 현황", image: "smallcircle.circle.fill")
                
                LearningSituationView(
                    learningKanjiList: viewModel.state.learningKanjiList
                )
                
                MyPageSection(title: "급수별 학습 현황", image: "book.circle.fill")
                
                LearningReportView(
                    learningKanjiList: viewModel.state.learningKanjiList
                )
                
                MyPageSection(title: "일주일간 학습 시간 현황", image: "clock.fill")
                
                LearningTimeReport(
                    data: viewModel.state.dailyStudySummary
                )
            }
            .padding(.horizontal, 20)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("학습 현황 리포트")
    }
}

fileprivate struct LearningReportView: View {
    
    let data: [(type: String, count: Int)]
    
    private let pointColor: [String: Color] = [
        JLPTGrade.N1.rawValue: Color.N1.main,
        JLPTGrade.N2.rawValue: Color.N2.main,
        JLPTGrade.N3.rawValue: Color.N3.main,
        JLPTGrade.N4.rawValue: Color.N4.main,
        JLPTGrade.N5.rawValue: Color.N5.main
    ]
    
    init(learningKanjiList: [LearningKanji]) {
        let dic = Dictionary(grouping: learningKanjiList.map { $0.kanji }, by: { $0.grade })
        var results: [(type: String, Int)] = []
        
        for (key, value) in dic {
            let result = (key.rawValue, value.count)
            results.append(result)
        }
        
        self.data = results.sorted(by: { $0.type > $1.type })
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Chart(data, id: \.type) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .cornerRadius(8.0)
                .foregroundStyle(by: .value("Type", item.type))
            }
            .chartLegend(.hidden)
            .chartForegroundStyleScale([
                JLPTGrade.N1.rawValue: JLPTGrade.N1.gradientColor,
                JLPTGrade.N2.rawValue: JLPTGrade.N2.gradientColor,
                JLPTGrade.N3.rawValue: JLPTGrade.N3.gradientColor,
                JLPTGrade.N4.rawValue: JLPTGrade.N4.gradientColor,
                JLPTGrade.N5.rawValue: JLPTGrade.N5.gradientColor
            ])
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("급수별 학습 단어")
                    .font(.shoraiSans(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
                
                ForEach(data, id: \.type) { data in
                    LegendView(
                        title: data.type,
                        count: data.count,
                        color: pointColor[data.type] ?? .accent
                    )
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 2)
    }
}

fileprivate struct LearningTimeReport: View {
    
    private let data: [DailyStudy]
    
    init(data: [DailyStudy]) {
        self.data = Array(data.prefix(7))
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Chart(data, id: \.date) { item in
                BarMark(
                    x: .value("날짜", item.date.shotStringFormat),
                    y: .value("학습 시간(초)", item.totalStudyMinutes)
                )
                .foregroundStyle(.blue.gradient)
                .cornerRadius(6.0)
                .annotation(position: .top) {
                    Text(createAnnotationText(item.totalStudyMinutes))
                        .font(.shoraiSans(size: 9, weight: .light))
                        .foregroundStyle(.gray)
                }
                
            }
            .chartLegend(.hidden)
            .chartYAxis(.hidden)
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 2)
    }
    
    private func createAnnotationText(_ time: Int) -> String {
        var minute = time / 60
        let second = time % 60
        
        if minute >= 60 {
            let hour = minute / 60
            minute = minute % 60
            return "\(hour)시간 \(minute)분"
            
        } else if second > 0 {
            return "\(minute)분 \(second)초"
            
        } else {
            return "\(minute)분"
        }
    }
}
