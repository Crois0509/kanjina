//
//  DIContainer.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

// MARK: - DIContainer

@MainActor
final class DIContainer {
    lazy var kanjiManager = KanjiDataManager()
    lazy var coreDataManager = CoreDataManager()
    
    lazy var appViewModel = AppViewModel(
        kanjiManager: kanjiManager,
        coreDataManager: coreDataManager
    )
    lazy var kanjiViewModel = KanjiViewModel(
        coreDataManager: appViewModel
    )
}
