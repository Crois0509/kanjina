//
//  SettingCoordinator.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI
import Combine

// MARK: - MyPageCoordinator Route

enum MyPageRoute: Hashable {
    case home
    case situation
}

// MARK: - MyPageCoordinator Model

final class MyPageCoordinator: Coordinator {
    typealias Route = MyPageRoute
    
    @Published private var _path = NavigationPath()
    
    var path: Binding<NavigationPath> {
        Binding(
            get: { self._path },
            set: { newRoute in self._path = newRoute }
        )
    }
}

// MARK: - MyPageCoordinator Method

extension MyPageCoordinator {
    func push(_ view: MyPageRoute) {
        _path.append(view)
    }
    
    func pop(_ count: Int = 1) {
        _path.removeLast(count)
    }
    
    func popToRoot() {
        _path.removeLast(_path.count - 1)
    }
    
    @ViewBuilder
    func build(_ view: MyPageRoute) -> some View {
        switch view {
        case .home: MyPageView()
        case .situation: LearningSituationDetailView()
        }
    }
}
