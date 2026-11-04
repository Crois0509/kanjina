//
//  LearnedVocaView.swift
//  kanjina
//
//  Created by 장상경 on 5/8/26.
//

import SwiftUI

// MARK: - LearnedVoca View

struct LearnedVocaView: View {
    
    enum LearnedVocaType: String, CaseIterable {
        case all = "전체"
        case studied = "알고 있음"
        case needToStudy = "모름"
    }
    
    @EnvironmentObject private var coordinator: VocabularyNoteCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    @EnvironmentObject private var sheetState: SheetState
    
    @State private var searchInput = ""
    @State private var selectIndex = 0
    @State private var isMemorizationMode = false
    
    // 검색&필터링된 한자 리스트
    private var resultList: [(title: String, items: [LearningKanji])] {
        let type = LearnedVocaType.allCases[selectIndex]
        
        return viewModel.state.searchLearnedKanjiList.compactMap { list in
            switch type {
            case .all:
                return list
                
            case .studied:
                return (list.title, list.items.filter { $0.isSuccessful })
                
            case .needToStudy:
                let items = list.items.filter { !$0.isSuccessful }
                if items.isEmpty {
                    return nil
                } else {
                    return (list.title, items)
                }
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 16) {
                    // 검색바
                    CommonSearchView(
                        input: $searchInput,
                        placeholder: "한자, 뜻, 히라가나 등으로 검색해 주세요"
                    )
                    .padding(.horizontal, 20)
                    
                    // 세그먼트 컨트롤 (학습 상태 선택)
                    CommonSegmentedControl(
                        selection: $selectIndex,
                        items: LearnedVocaType.allCases.map { $0.rawValue }
                    )
                    
                    // 한자 리스트
                    if resultList.allSatisfy({ $0.items.isEmpty }) {
                        Text(searchInput.isEmpty ? "학습한 단어가 없습니다." : "검색 결과가 없습니다.")
                            .multilineTextAlignment(.center)
                            .font(.shoraiSans(size: 18, weight: .demi))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(resultList, id: \.title) { section in
                                        CommonSectionView(title: section.title)
                                        
                                        ForEach(section.items, id: \.kanji) { item in
                                            ListCell(
                                                isMemorizationMode: $isMemorizationMode,
                                                element: (item.kanji, item.isSuccessful),
                                                superViewSize: geometry.size,
                                                type: .learned
                                            )
                                            .padding(.top, 12)
                                            .onTapGesture {
                                                setSheetState(item)
                                                sheetState.isShowSheet = true
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 10)
                            }
                            .scrollDismissesKeyboard(.immediately)
                            .overlay(alignment: .trailing) {
                                CommonScrollIndicatorView(
                                    indicatorTitles: resultList.map { $0.title },
                                    action: { title in
                                        withAnimation {
                                            scrollProxy.scrollTo(title, anchor: .top)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.top, 10)
            }
            .overlay(alignment: .bottomTrailing) {
                MemorizationButton(isMemorizationMode: $isMemorizationMode)
                    .padding()
            }
        }
        .navigationTitle("학습한 단어장")
        .onAppear {
            viewModel.updateLearnedSearch(for: "")
        }
        .onDisappear {
            viewModel.resetSearch()
        }
        .onChange(of: searchInput) { _, newValue in
            viewModel.updateLearnedSearch(for: newValue)
        }
    }
    
    /// 한자 상세 정보를 표시하는 Sheet를 설정하는 메서드
    /// - Parameter item: 학습한 한자 정보
    private func setSheetState(_ item: LearningKanji) {
        sheetState.kanji = item.kanji
        sheetState.isSuccessful = item.isSuccessful
        sheetState.isBookmarked = viewModel.checkBookmarked(kanji: item.kanji)
    }
}

#Preview {
    LearnedVocaView()
}
