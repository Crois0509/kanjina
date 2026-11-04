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
            .id(resetTrigger) // 데이터 초기화 시 UI 새로고침을 위한 ID 지정
        }
    }
}
