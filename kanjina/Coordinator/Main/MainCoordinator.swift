//
//  MainCoordinator.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import Foundation
import Combine

// MARK: - MainCoordinator Model

final class MainCoordinator: ObservableObject {
    @Published var learningCoordinator: LearningCoordinator
    @Published var vocabularyNoteCoordinator: VocabularyNoteCoordinator
    @Published var settingCoordinator: MyPageCoordinator
        
    init() {
        self.learningCoordinator = LearningCoordinator()
        self.vocabularyNoteCoordinator = VocabularyNoteCoordinator()
        self.settingCoordinator = MyPageCoordinator()
    }
}
