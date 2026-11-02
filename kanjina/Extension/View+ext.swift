//
//  View+ext.swift
//  kanjina
//
//  Created by 장상경 on 5/16/26.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
