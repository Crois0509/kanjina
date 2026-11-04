//
//  SerachBar.swift
//  kanjina
//
//  Created by 장상경 on 5/8/26.
//

import SwiftUI

/// 공용 검색 뷰
struct CommonSearchView: View {
    
    @Binding var input: String
    var placeholder: String
    
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray)
                
                TextField(placeholder, text: $input)
                    .foregroundStyle(.black)
                    .font(.shoraiSans(size: 16, weight: .regular))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 10)
                
                if !input.isEmpty {
                    Button {
                        input = ""
                        
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
        }
        .background(.gray.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    CommonSearchView(input: .constant("test"), placeholder: "검색어를 입력하세요.")
}
