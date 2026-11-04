//
//  Coordinator.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

// MARK: - Coordinator Protocol

protocol Coordinator: ObservableObject {
    associatedtype Route: Hashable // 이동할 경로
    
    var path: Binding<NavigationPath> { get }
    
    func push(_ view: Route)
    func pop(_ count: Int)
    func popToRoot()
}
