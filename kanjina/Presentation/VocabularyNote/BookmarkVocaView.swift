//
//  BookmarVocaView.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import SwiftUI

// MARK: - BookmarkVoca View

struct BookmarkVocaView: View {
    
    @EnvironmentObject private var coordinator: VocabularyNoteCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    @EnvironmentObject private var toolbarState: ToolBarState
    @EnvironmentObject private var sheetState: SheetState
    
    @State private var isMemorizationMode: Bool = false
    @State private var searchInput = ""
    
    // 한자의 검색, 필터링 결과 값을 담는 배열
    private var resultList: [(title: String, items: [Kanji])] {
        let query = searchInput.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else {
            return viewModel.groupedList(viewModel.state.bookmarkKanjiList)
        }
        let filteredList = viewModel.state.bookmarkKanjiList.filter { $0.searchKey.contains(query) }
        return viewModel.groupedList(filteredList)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack(alignment: .center, spacing: 0) {
                    // 검색바
                    CommonSearchView(
                        input: $searchInput,
                        placeholder: "한자, 뜻, 히라가나 등으로 검색해 주세요"
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    // 한자 리스트
                    if resultList.isEmpty {
                        Text(searchInput.isEmpty ? "북마크된 단어가 없습니다." : "검색 결과가 없습니다.")
                            .multilineTextAlignment(.center)
                            .font(.shoraiSans(size: 18, weight: .demi))
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(alignment: .center, spacing: 0) {
                                    ForEach(resultList, id: \.title) { section in
                                        CommonSectionView(title: section.title)
                                        
                                        ForEach(section.items, id: \.id) { item in
                                            ListCell(
                                                isMemorizationMode: $isMemorizationMode,
                                                element: (item, nil),
                                                superViewSize: geometry.size,
                                                type: .bookmark
                                            )
                                            .padding(.bottom, 12)
                                            .onTapGesture {
                                                setSheetState(item)
                                                sheetState.isShowSheet = true
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                                .padding(.bottom, 20)
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
            }
            .padding(.top, 10)
            .overlay(alignment: .bottomTrailing) {
                MemorizationButton(isMemorizationMode: $isMemorizationMode)
                    .padding()
            }
        }
        .navigationTitle("북마크")
        .onAppear {
            setToolbarState()
        }
        .onDisappear {
            toolbarState.reset()
        }
    }
}

// MARK: - BookmarkVoca View Private Method

private extension BookmarkVocaView {
    /// 툴바 버튼을 설정하는 메서드
    /// - **북마크된 한자가 있는 경우**: 북마크 한자를 활용한 학습모드 기능 설정
    /// - **북마크된 한자가 없는 경우**: 경고 Alert 설정
    func setToolbarState() {
        toolbarState.isRightButtonVisible = true
        toolbarState.requiresAlert = true
        toolbarState.rightButtonIcon = "long.text.page.and.pencil.fill"
        
        if resultList.isEmpty {
            toolbarState.alertTitle = "북마크가 없습니다."
            toolbarState.alertMessage = "북마크 단어로 학습을 하고싶으시면 학습을 통해 북마크를 추가해 주세요."
            
        } else {
            toolbarState.alertTitle = "북마크 학습을 시작하시겠습니까?"
            toolbarState.alertMessage = "북마크에 저장된 단어로 단어 학습을 시작합니다."
            toolbarState.rightButtonAction = {
                coordinator.push(.bookmarkLearning)
            }
        }
    }
    
    /// 한자의 상세 설명을 담은 시트를 설정하는 메서드
    /// - Parameter item: 한자 정보
    func setSheetState(_ item: Kanji) {
        sheetState.isBookmarked = true
        sheetState.kanji = item
        if let learningItem = viewModel.state.learningKanjiList.first(where: { $0.kanji.kanji == item.kanji && $0.kanji.grade == item.grade }) {
            sheetState.isSuccessful = learningItem.isSuccessful
            
        } else {
            sheetState.isSuccessful = nil
        }
    }
}
