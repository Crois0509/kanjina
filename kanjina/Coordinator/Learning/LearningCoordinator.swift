//
//  LearningCoordinator.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

enum LearningRoute: Hashable {
    case home
    case learning
    case complete
}

final class LearningCoordinator: Coordinator {
    typealias Route = LearningRoute
    
    @Published private var _path = NavigationPath()
    
    var path: Binding<NavigationPath> {
        Binding(
            get: { self._path },
            set: { newRoute in self._path = newRoute }
        )
    }
}

extension LearningCoordinator {
    func push(_ view: LearningRoute) {
        _path.append(view)
    }
    
    func pop(_ count: Int = 1) {
        _path.removeLast(count)
    }
    
    func popToRoot() {
        _path.removeLast(_path.count)
    }
    
    @MainActor
    @ViewBuilder
    func build(_ view: LearningRoute) -> some View {
        switch view {
        case .home:
            LearningSelectView()
            
        case .learning:
            LearningView(onPushToView: { [weak self] in
                self?.push(.complete)
            })
            
        case .complete:
            CompleteView(onBackAction: { [weak self] in
                self?.popToRoot()
            })
        }
    }
}
