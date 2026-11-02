//
//  ToolBarState.swift
//  kanjina
//
//  Created by 장상경 on 5/15/26.
//

import SwiftUI
import Combine

final class ToolBarState: ObservableObject {
    @Published var isRightButtonVisible: Bool = false
    @Published var rightButtonIcon: String = ""
    
    @Published var showAlert: Bool = false
    @Published var requiresAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    var rightButtonAction: (() -> Void)? = nil
    
    func reset() {
        isRightButtonVisible = false
        rightButtonIcon = ""
        rightButtonAction = nil
        showAlert = false
        alertTitle = ""
        alertMessage = ""
    }
}
