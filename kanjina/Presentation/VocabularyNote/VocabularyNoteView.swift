//
//  VocabularyNoteView.swift
//  kanjina
//
//  Created by 장상경 on 5/7/26.
//

import SwiftUI

/// 단어장 타입
enum VocaType {
    case all
    case learned
    case bookmark
    
    var image: String {
        switch self {
        case .all:
            return "text.book.closed.fill"
        case .learned:
            return "book.closed.fill"
        case .bookmark:
            return "bookmark.fill"
        }
    }
}

/// 단어장을 나누기 위한 객체 타입
struct Note: Hashable {
    let id = UUID()
    let title: String
    let description: String
    let route: VocabularyNoteRoute
    let type: VocaType
}

// MARK: - VocabularyNote View

struct VocabularyNoteView: View {
    
    @EnvironmentObject private var coordinator: VocabularyNoteCoordinator
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    // 표시할 단어장 목록 배열
    private let noteList: [Note] = [
        .init(
            title: "단어 사전",
            description: "모든 단어 목록을\n볼 수 있습니다.",
            route: .allVoca,
            type: .all
        ),
        .init(
            title: "학습한 단어장",
            description: "학습한 단어 목록을\n볼 수 있습니다.",
            route: .learnedVoca,
            type: .learned
        ),
        .init(
            title: "북마크",
            description: "북마크한 단어 목록을\n볼 수 있습니다.",
            route: .bookmark,
            type: .bookmark
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("단어장")
                .foregroundStyle(Color.black)
                .font(.shoraiSans(size: 32, weight: .bold))
                .padding(.bottom, 8)
            
            Text("원하는 단어장을 선택하고 학습해 보세요!")
                .foregroundStyle(Color.secondary)
                .font(.shoraiSans(size: 16, weight: .regular))
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(noteList, id: \.id) { note in
                        VocaButtonView(
                            title: note.title,
                            description: note.description,
                            type: note.type,
                            action: { coordinator.push(note.route) }
                        )
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 4)
                }
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 10)
        .padding(.horizontal, 20)
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

// MARK: - VocabularyNote View Private UI

/// 단어장 카드 UI
fileprivate struct VocaButtonView: View {
    var title: String
    var description: String
    let type: VocaType
    var action: () -> Void
    
    private var imageBG: LinearGradient {
        switch type {
        case .all:
            return LinearGradient(
                colors: [.white.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        default:
            return LinearGradient(
                colors: [.N5.main, .accent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        }
    }
    
    private var bacgroundColor: LinearGradient {
        switch type {
        case .all:
            return LinearGradient(
                colors: [.N4.secondary, .N4.main],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        default:
            return LinearGradient(
                colors: [.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
        }
    }
    
    var body: some View {
        Button {
            action()
            
        } label: {
            HStack(spacing: 20) {
                Image(systemName: type.image)
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(imageBG)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(type == .all ? .white : .black)
                        .font(.shoraiSans(size: 18, weight: .demi))
                    
                    Text(description)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(type == .all ? .white.opacity(0.8) : .gray)
                        .font(.shoraiSans(size: 14, weight: .regular))
                }
                .padding(.vertical, 20)
                
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .frame(width: 10, height: 20)
                    .foregroundStyle(type == .all ? .white : .gray)
            }
            .padding(.horizontal, 24)
            .background(bacgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(type == .all ? Color.N4.secondary : Color.gray, lineWidth: 0.5)
                    .opacity(0.4)
            }
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
        }
    }
}

#Preview {
    VocabularyNoteView()
}
