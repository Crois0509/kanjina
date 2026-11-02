//
//  VocabularyNoteCoordinator.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

enum VocabularyNoteRoute: Hashable {
    case home
    case learnedVoca
    case allVoca
    case bookmark
    case bookmarkLearning
    case learningComplete
}

final class VocabularyNoteCoordinator: Coordinator {
    typealias Route = VocabularyNoteRoute
    
    @Published private var _path = NavigationPath()
    
    var path: Binding<NavigationPath> {
        Binding(
            get: { self._path },
            set: { newRoute in self._path = newRoute }
        )
    }
}

extension VocabularyNoteCoordinator {
    func push(_ view: VocabularyNoteRoute) {
        _path.append(view)
    }
    
    func pop(_ count: Int = 1) {
        _path.removeLast(count)
    }
    
    func popToRoot() {
        _path.removeLast(_path.count - 1)
    }
    
    @MainActor
    @ViewBuilder
    func build(_ view: VocabularyNoteRoute) -> some View {
        switch view {
        case .home:
            VocabularyNoteView()
            
        case .learnedVoca:
            LearnedVocaView()
            
        case .allVoca:
            AllVocaList()
            
        case .bookmark:
            BookmarkVocaView()
            
        case .bookmarkLearning:
            LearningView(onPushToView: { [weak self] in
                self?.push(.learningComplete)
            })
            
        case .learningComplete:
            CompleteView(onBackAction: { [weak self] in
                self?.pop(2)
            })
        }
    }
}
