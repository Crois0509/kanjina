//
//  AllVocaList.swift
//  kanjina
//
//  Created by 장상경 on 5/8/26.
//

import SwiftUI

struct AllVocaListView: View {
    
    @EnvironmentObject private var coordinator: VocabularyNoteCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    @EnvironmentObject private var sheetState: SheetState
    
    @State private var selectedIndex = 0
    @State private var searchInput = ""
    @State private var isMemorizationMode = false
    
    private let grades: [String] = JLPTGrade.allCases.map { $0.rawValue }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 16) {
                    CommonSearchView(
                        input: $searchInput,
                        placeholder: "한자, 뜻, 히라가나 등으로 검색해 주세요"
                    )
                    .padding(.horizontal, 20)
                    
                    CommonSegmentedControl(
                        selection: $selectedIndex,
                        items: grades
                    )
                    
                    if viewModel.state.searchVocaKanjiList.isEmpty {
                        Text(searchInput.isEmpty ? "단어장을 불러올 수 없습니다.\n잠시후 다시 시도해주세요." : "검색 결과가 없습니다.")
                            .multilineTextAlignment(.center)
                            .font(.shoraiSans(size: 18, weight: .demi))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.state.searchVocaKanjiList, id: \.title) { section in
                                        CommonSectionView(title: section.title)
                                        
                                        ForEach(section.items, id: \.id) { kanji in
                                            ListCell(
                                                isMemorizationMode: $isMemorizationMode,
                                                element: (kanji, nil),
                                                superViewSize: geometry.size,
                                                type: .all
                                            )
                                            .padding(.top, 12)
                                            .onTapGesture {
                                                setSheetState(kanji)
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
                                    indicatorTitles: viewModel.state.searchVocaKanjiList.map { $0.title },
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
            }
            .padding(.top, 10)
            .navigationTitle("단어 사전")
            .overlay(alignment: .bottomTrailing) {
                MemorizationButton(isMemorizationMode: $isMemorizationMode)
                    .padding()
            }
        }
        .onChange(of: searchInput) { _, newValue in
            viewModel.updateVocaSearch(for: newValue, segmentIndex: selectedIndex)
        }
        .onChange(of: selectedIndex) { _, newValue in
            viewModel.updateVocaSearch(for: searchInput, segmentIndex: newValue)
        }
        .onAppear {
            viewModel.updateVocaSearch(for: "", segmentIndex: selectedIndex)
        }
    }
}

private extension AllVocaListView {
    func setSheetState(_ item: Kanji) {
        sheetState.kanji = item
        sheetState.isBookmarked = viewModel.checkBookmarked(kanji: item)
        
        if let learnedItem = viewModel.state.learningKanjiList.first(where: { $0.kanji.kanji == item.kanji && $0.kanji.grade == item.grade }) {
            sheetState.isSuccessful = learnedItem.isSuccessful
        } else {
            sheetState.isSuccessful = nil
        }
    }
}

