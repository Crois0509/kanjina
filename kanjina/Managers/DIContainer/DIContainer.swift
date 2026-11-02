//
//  DIContainer.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

@MainActor
final class DIContainer {
    lazy var viewModel = KanjiViewModel(coreDataManager: coreDataManager)
    lazy var coreDataManager = CoreDataManager()
}
