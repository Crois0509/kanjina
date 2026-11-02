//
//  CommonScrollIndicatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/17/26.
//

import SwiftUI

struct CommonScrollIndicatorView: View {
    
    let indicatorTitles: [String]
    let action: (String) -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ForEach(indicatorTitles, id: \.self) { title in
                Text(title)
                    .font(.shoraiSans(size: 11, weight: .medium))
                    .foregroundStyle(.blue)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 30, height: 20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        action(title)
                    }
            }
        }
        .padding(.trailing, 2)
    }
}

