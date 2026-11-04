//
//  CommonSectionView.swift
//  kanjina
//
//  Created by 장상경 on 5/17/26.
//

import SwiftUI

/// 공용 한자 섹션 뷰
struct CommonSectionView: View {
    
    let title: String
    
    var body: some View {
        HStack {
            Text(title + (title == "기타" ? "" : "행"))
                .font(.shoraiSans(size: 16, weight: .medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .id(title)
    }
}

