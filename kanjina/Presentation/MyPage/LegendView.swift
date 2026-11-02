//
//  LegendView.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import SwiftUI

struct LegendView: View {
    
    var title: String
    var count: Int
    var color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .frame(width: 10, height: 10)
                .foregroundStyle(color)
            
            Text(title)
                .font(.shoraiSans(size: 14, weight: .regular))
                .foregroundStyle(.gray)
            
            Spacer()
            
            Text("\(count)개")
                .font(.shoraiSans(size: 14, weight: .regular))
                .foregroundStyle(.black)
        }
    }
}
