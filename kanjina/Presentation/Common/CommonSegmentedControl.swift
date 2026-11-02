//
//  CommonSegmentedControl.swift
//  kanjina
//
//  Created by 장상경 on 5/12/26.
//

import SwiftUI

struct CommonSegmentedControl: View {
    
    @Binding var selection: Int
    let items: [String]
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { index in
                ZStack {
                    if selection == index {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.white)
                            .frame(height: 36)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.gray, lineWidth: 0.5)
                                    .opacity(0.4)
                            }
                            .padding(.horizontal, 4)
                            .matchedGeometryEffect(id: "segment_background", in: animation)
                    }
                    
                    Text(items[index])
                        .font(.shoraiSans(size: 16, weight: .demi))
                        .foregroundStyle(selection == index ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .zIndex(1)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = index
                    }
                }
            }
        }
        .padding(2)
        .background(.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}

#Preview {
    CommonSegmentedControl(
        selection: .constant(0),
        items: JLPTGrade.allCases.map { $0.rawValue }
    )
}
