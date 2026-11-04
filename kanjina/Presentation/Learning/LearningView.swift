//
//  LearningView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

// MARK: - Learning View

struct LearningView: View {
    
    // MARK: - State Properties
    
    // App State
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    @AppStorage(UserDefaultsConfig.timeLimit) private var timeLimit: Int = 5
    
    @State private var navTitle: String?
    
    // Button State
    @State private var failButtonIsDisabled: Bool = false
    @State private var reviewMode: Bool = false
    
    // Timer State
    @State private var saveSeconds: Int = 0
    @State private var saveRemainingTime: Int = 0
    
    // Question State
    @State private var questions: [Kanji] = []
    @State private var solvedQuestions: [ProgressState] = []
    @State private var questionIndex: Int = 0
    
    // Learning State
    @State private var hangleIsHidden: Bool = true
    @State private var hiraganaIsHidden: Bool = true
    @State private var bookmarkCurrentWord: Bool = false
    @State private var bookmarkButtonIsHidden: Bool = false
    
    // Alert State
    @State private var isShowingLearningStopAlert: Bool = false
    @State private var isShowingReviewAlert: Bool = false
    @State private var isShowingDangerAlert: Bool = false
        
    // Button Grid
    private let grids: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 10),
        count: 2
    )
    
    // Question Help Properties
    private var questionsCount: Int { questions.count }
    private var failQuestionCount: Int { solvedQuestions.count(where: { $0.qState != .success }) }
    
    // Navigation Help Closure
    var onPushToView: () -> Void
    
    // MARK: - UI
    
    var body: some View {
        VStack(alignment: .center) {
            // Top Header
            HStack {
                Text("공부시간: \(viewModel.state.learningTime.formatTime)")
                    .foregroundStyle(.black)
                    .font(.shoraiSans(size: 16, weight: .medium))
                
                Spacer()
                
                Text("진행 상황: \(min(questions.count, solvedQuestions.count + 1))/\(questions.count)")
                    .foregroundStyle(.black)
                    .font(.shoraiSans(size: 16, weight: .medium))
            }
            
            LearningProgressView(
                maxPoint: questionsCount,
                current: $solvedQuestions
            )
            .frame(maxWidth: .infinity)
            
            // Main Question
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 4.0)
                    .overlay(alignment: .topTrailing) {
                        if !bookmarkButtonIsHidden {
                            Button {
                                bookmarkCurrentWord.toggle()
                                
                            } label: {
                                Image(systemName: bookmarkCurrentWord ? "bookmark.fill" : "bookmark")
                                    .foregroundStyle(bookmarkCurrentWord ? .accent : .gray)
                                    .font(.system(size: 24))
                            }
                            .padding()
                        }
                    }
                
                VStack(alignment: .center, spacing: 10) {
                    if !questions.isEmpty {
                        Text(questions[questionIndex].hiragana)
                            .animation(.smooth, value: hiraganaIsHidden)
                            .foregroundStyle(hiraganaIsHidden ? .white : .secondary)
                            .font(.shoraiSans(size: 30, weight: .medium))
                        
                        Text(questions[questionIndex].kanji)
                            .foregroundStyle(Color.black)
                            .font(.shoraiSans(size: 48, weight: .bold))
                        
                        Text(questions[questionIndex].meaningKo)
                            .animation(.smooth, value: hangleIsHidden)
                            .foregroundStyle(hangleIsHidden ? .white : .green)
                            .font(.shoraiSans(size: 30, weight: .medium))
                    }
                }
            }
            .padding(.vertical, 20)
            
            // Buttons
            LazyVGrid(columns: grids, alignment: .center, spacing: 10) {
                Button("한국어") {
                    hangleIsHidden = false
                }
                .disabled(!hangleIsHidden)
                .buttonStyle(
                    ActiveButtonStyle(
                        isDisabled: !hangleIsHidden,
                        color: .orange
                    )
                )
                
                Button("히라가나") {
                    hiraganaIsHidden = false
                }
                .disabled(!hiraganaIsHidden)
                .buttonStyle(
                    ActiveButtonStyle(
                        isDisabled: !hiraganaIsHidden,
                        color: .orange
                    )
                )
                
                Button("모름") {
                    let answer = ProgressState(id: questionIndex, qState: .fail)
                    if !hangleIsHidden && !hiraganaIsHidden {
                        solvedQuestions.append(answer)
                        resetState()
                        
                    } else {
                        hangleIsHidden = false
                        hiraganaIsHidden = false
                        failButtonIsDisabled = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            solvedQuestions.append(answer)
                            resetState()
                        }
                    }
                }
                .disabled(failButtonIsDisabled)
                .buttonStyle(
                    ActiveButtonStyle(
                        isDisabled: failButtonIsDisabled,
                        color: .red
                    )
                )
                
                Button("알고있음") {
                    let answer = ProgressState(
                        id: questionIndex,
                        qState: viewModel.state.remainingTime <= 0 ? .trial : .success
                    )
                    solvedQuestions.append(answer)
                    resetState()
                }
                .disabled(failButtonIsDisabled)
                .buttonStyle(
                    ActiveButtonStyle(
                        isDisabled: failButtonIsDisabled,
                        color: .blue
                    )
                )
            }
            .shadow(color: .black.opacity(0.2), radius: 2)
            .padding(.bottom, 20)
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .navigationTitle(navTitle ?? "")
        .toolbarVisibility(.hidden, for: .tabBar)
        .task {
            if let kanjiList = viewModel.state.currentLearningKanjiList {
                self.questions = kanjiList.kanjis.shuffled()
                self.navTitle = kanjiList.kanjis.first?.grade.rawValue
                
            } else if !viewModel.state.bookmarkKanjiList.isEmpty {
                self.questions = viewModel.state.bookmarkKanjiList.shuffled()
                self.bookmarkButtonIsHidden = true
                self.navTitle = "북마크 단어학습"
                
            } else {
                self.isShowingDangerAlert = true
                debugPrint("🚨 문제를 불러오는데 실패했습니다.")
                return
            }
            
            bookmarkCurrentWord = viewModel.checkBookmarked(kanji: questions[questionIndex])
            viewModel.state.remainingTime = timeLimit
            viewModel.startTimer()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                saveSeconds = viewModel.state.learningTime
                saveRemainingTime = viewModel.state.remainingTime
            } else if newPhase == .active {
                viewModel.state.learningTime = saveSeconds
                viewModel.state.remainingTime = saveRemainingTime
            }
        }
        .toolbar {
            CommonToolbar {
                isShowingLearningStopAlert = true
            }
        }
        .alert("정말 학습을 그만두시겠어요?",isPresented: $isShowingLearningStopAlert) {
            Button("취소", role: .cancel) {
                isShowingLearningStopAlert = false
            }
            
            Button("확인", role: .destructive) {
                isShowingLearningStopAlert = false
                viewModel.state.currentLearningKanjiList = nil
                dismiss()
            }
            .foregroundStyle(.red)
        } message: {
            Text("지금 종료하시면 학습 내용이 기록되지 않습니다.")
        }
        .alert("모르는 단어를 복습하시겠어요?", isPresented: $isShowingReviewAlert) {
            Button("복습하기", role: .cancel) {
                setReviewLearning()
            }
            
            Button("학습 종료", role: .destructive) {
                onPushToView()
            }
        } message: {
            Text("모르는 단어 수: \(failQuestionCount)\n복습을 통해 학습 달성률을 높일 수 있습니다.")
        }
        .alert("문제가 발생했습니다.", isPresented: $isShowingDangerAlert) {
            Button("확인", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("단어 목록을 불러오는데 실패했습니다.\n잠시후 다시 시도해주세요.")
        }
    }
}

// MARK: - Learning View Method

extension LearningView {
    /// 현재 화면의 상태를 초기화 하는 메서드
    /// - 다음 문제로 넘어가기 전 상태 초기화
    func resetState() {
        withAnimation(.bouncy) {
            let current = questions[questionIndex]
            let state = solvedQuestions[questionIndex].qState
            viewModel.checkAnswer(kanji: current, isCorrect: state, isBookmark: bookmarkCurrentWord)
            
            hangleIsHidden = true
            hiraganaIsHidden = true
            failButtonIsDisabled = false
            bookmarkCurrentWord = false
            viewModel.state.remainingTime = timeLimit
            
            if questionIndex < questions.count - 1 {
                questionIndex += 1
                if reviewMode {
                    let current = questions[questionIndex]
                    let isBookmarked = viewModel.state.pendingResults.first(where: { $0.kanji == current })?.bookmark
                    bookmarkCurrentWord = isBookmarked ?? false
                    
                } else {
                    bookmarkCurrentWord = viewModel.checkBookmarked(kanji: questions[questionIndex])
                }
                
            } else {
                if viewModel.state.pendingResults.allSatisfy({ $0.state == .success }) {
                    onPushToView()
                    
                } else {
                    viewModel.pauseTimer()
                    isShowingReviewAlert = true
                }
            }
        }
    }
    
    /// 다시 학습을 위한 세팅을 하는 메서드
    /// - 학습을 마친 후 다시 학습을 선택할 시 초기 상태로 초기화를 위한 메서드
    func setReviewLearning() {
        reviewMode = true
        questionIndex = 0
        hangleIsHidden = true
        hiraganaIsHidden = true
        failButtonIsDisabled = false
        solvedQuestions = []
        questions = viewModel.state.pendingResults
            .filter { $0.state != .success }
            .map { $0.kanji }
            .shuffled()
        viewModel.state.remainingTime = timeLimit
        viewModel.startTimer()
        let current = questions[questionIndex]
        let isBookmarked = viewModel.state.pendingResults.first(where: { $0.kanji == current })?.bookmark
        bookmarkCurrentWord = isBookmarked ?? false
    }
}
