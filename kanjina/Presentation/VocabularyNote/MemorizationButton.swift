//
//  MemorizationButton.swift
//  kanjina
//
//  Created by 장상경 on 5/12/26.
//

import SwiftUI

struct MemorizationButton: View {
    
    @Binding var isMemorizationMode: Bool
    
    var body: some View {
        Button {
            withAnimation {
                isMemorizationMode.toggle()
            }
            
        } label: {
            Image(systemName: isMemorizationMode ? "eye.slash.fill" : "eye.fill")
                .font(.system(size: 24))
                .foregroundStyle(isMemorizationMode ? .white : .gray)
                .padding(14)
                .background(isMemorizationMode ? .accent : .white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 2)
        }
    }
}
