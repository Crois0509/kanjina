//
//  ListCell.swift
//  kanjina
//
//  Created by 장상경 on 5/8/26.
//

import SwiftUI

struct ListCell: View {
    
    @Binding var isMemorizationMode: Bool
    
    var element: (kanji: Kanji, isSuccessful: Bool?)
    var superViewSize: CGSize
    var type: VocaType
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(element.kanji.kanji)
                .foregroundStyle(.black)
                .font(.shoraiSans(size: 18, weight: .bold))
                .frame(width: superViewSize.width / 3.0)
            
            VStack(alignment: .leading, spacing: 8) {
                if type == .learned {
                    HStack(spacing: 10) {
                        Text(element.kanji.grade.rawValue)
                            .foregroundStyle(.black)
                            .font(.shoraiSans(size: 12, weight: .regular))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text(element.isSuccessful == true ? "✓ 알고 있음" : "ⅹ 모름")
                            .foregroundStyle(element.isSuccessful == true ? .green : .red)
                            .font(.shoraiSans(size: 12, weight: .regular))
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(element.isSuccessful == true ? .green.opacity(0.2) : .red.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                Text(element.kanji.hiragana)
                    .foregroundStyle(.gray)
                    .font(.shoraiSans(size: 14, weight: .regular))
                
                Text(element.kanji.meaningKo)
                    .foregroundStyle(.accent)
                    .font(.shoraiSans(size: 16, weight: .medium))
            }
            .blur(radius: isMemorizationMode ? 8 : 0)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 0.5)
                .opacity(0.4)
        }
        .shadow(color: .black.opacity(0.2), radius: 2)
    }
}
