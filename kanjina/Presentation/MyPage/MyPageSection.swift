//
//  MyPageSection.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import SwiftUI

struct MyPageSection: View {
    
    let title: String
    let image: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: image)
                .font(.system(size: 16))
                .foregroundStyle(.gray)
            
            Text(title)
                .font(.shoraiSans(size: 16, weight: .demi))
                .foregroundStyle(.gray)
            
            Spacer()
        }
    }
}
