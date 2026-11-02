//
//  LearningCoordinatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

struct LearningCoordinatorView: View {
    
    @EnvironmentObject private var coordinator: LearningCoordinator
    @EnvironmentObject private var kanjiViewModel: KanjiViewModel
    
    var body: some View {
        NavigationStack(path: coordinator.path) {
            VStack {
                coordinator.build(.home)
                    .navigationDestination(for: LearningRoute.self) { route in
                        coordinator.build(route)
                            .navigationBarBackButtonHidden(true)
                    }
                
                Spacer()
            }
        }
        .environmentObject(coordinator)
        .environmentObject(kanjiViewModel)
    }
}
