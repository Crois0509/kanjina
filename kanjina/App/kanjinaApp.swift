//
//  kanjinaApp.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

@main
struct kanjinaApp: App {
        
    @AppStorage(UserDefaultsConfig.resetTrigger) private var resetTrigger: String = UUID().uuidString
    
    private let diContainer = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(
                appCoordinator: AppCoordinator(),
                diContainer: diContainer
            )
            .id(resetTrigger)
        }
    }
}
