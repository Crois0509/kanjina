//
//  KanjiDetailView.swift
//  kanjina
//
//  Created by 장상경 on 5/16/26.
//

import SwiftUI

struct KanjiDetailView: View {
    
    @EnvironmentObject private var viewModel: KanjiViewModel
    
    @State var isBookmarked: Bool
    
    private let initialBookmarked: Bool
    
    let kanji: Kanji
    let isSuccessful: Bool?
    
    init(kanji: Kanji, isSuccessful: Bool?, isBookmarked: Bool,) {
        self.kanji = kanji
        self.isSuccessful = isSuccessful
        self.isBookmarked = isBookmarked
        self.initialBookmarked = isBookmarked
    }
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("한자 상세")
                    .font(.shoraiSans(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.2))
                    
                    Text(kanji.kanji)
                        .font(.shoraiSans(size: 48, weight: .bold))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .topTrailing) {
                    Button {
                        withAnimation {
                            isBookmarked.toggle()
                        }
                        
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(isBookmarked ? .accent : .gray)
                            .font(.system(size: 24))
                    }
                    .padding()
                }
                
                HStack(alignment: .center, spacing: 8) {
                    CommonCapsuleView(
                        title: kanji.grade.rawValue,
                        textColor: .white,
                        bgColor: kanji.grade.color
                    )
                    
                    if let isSuccessful {
                        CommonCapsuleView(
                            title: isSuccessful ? "알고있음" : "모름",
                            textColor: isSuccessful ? .green : .red,
                            bgColor: isSuccessful ? .green.opacity(0.1) : .red.opacity(0.1)
                        )
                    }
                    
                    Spacer()
                }
                
                CardView(title: "히라가나", contents: kanji.hiragana)
                
                CardView(title: "뜻", contents: kanji.meaningKo)
                
                Button {
                    withAnimation {
                        isBookmarked.toggle()
                    }
                    
                } label: {
                    Text(isBookmarked ? "북마크 해제" : "북마크")
                        .font(.shoraiSans(size: 18, weight: .demi))
                        .foregroundStyle(isBookmarked ? .gray : .white)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                .background(isBookmarked ? .gray.opacity(0.2) : .accent)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isBookmarked ? .gray : .blue, lineWidth: 0.5)
                        .opacity(0.5)
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
        }
        .onDisappear {
            if initialBookmarked != isBookmarked {
                viewModel.updateKanjiBookmarkState(kanji, isBookmarked: isBookmarked)
            }
        }
    }
}

fileprivate struct CardView: View {
    
    let title: String
    let contents: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.shoraiSans(size: 14, weight: .regular))
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity)
            
            Text(contents)
                .font(.shoraiSans(size: 18, weight: .medium))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray, lineWidth: 0.5)
                .opacity(0.5)
        }
    }
}
