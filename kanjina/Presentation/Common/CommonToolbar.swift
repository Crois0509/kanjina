//
//  CommonToolbar.swift
//  kanjina
//
//  Created by 장상경 on 5/13/26.
//

import SwiftUI

struct CommonToolbar: ToolbarContent {
    
    let onBack: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                onBack()
                
            } label: {
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.shoraiSans(size: 18, weight: .bold))
                }
                .frame(maxWidth: 44, maxHeight: 44, alignment: .center)
                .contentShape(Rectangle())
            }
        }
    }
}
