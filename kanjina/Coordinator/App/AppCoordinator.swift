//
//  AppCoordinator.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

// MARK: - AppCoordinator Model

final class AppCoordinator: ObservableObject {
    @Published var mainCoordinator = MainCoordinator()
    
    @ViewBuilder
    func build() -> some View {
        MainCoordinatorView()
            .environmentObject(mainCoordinator)
    }
}
