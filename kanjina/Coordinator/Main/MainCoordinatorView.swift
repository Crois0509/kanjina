//
//  MainCoordinatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

// MARK: - MainCoordinator Tab Enum

enum TabSelection: CaseIterable {
    case learning
    case vocabulary
    case setting
}

// MARK: - MainCoordinator View

struct MainCoordinatorView: View {
    
    @EnvironmentObject private var coordinator: MainCoordinator
    @EnvironmentObject private var kanjiViewModel: KanjiViewModel
    
    @State private var selection: TabSelection = .learning
    
    var body: some View {
        MainView(selection: $selection)
            .environmentObject(coordinator)
            .environmentObject(kanjiViewModel)
    }
}
