//
//  SettingCoordinatorView.swift
//  kanjina
//
//  Created by 장상경 on 5/6/26.
//

import SwiftUI

// MARK: - MyPageCoordinator View

struct MyPageCoordinatorView: View {
    
    @EnvironmentObject private var coordinator: MyPageCoordinator
    @EnvironmentObject private var kanjiViewModel: KanjiViewModel
    
    var body: some View {
        NavigationStack(path: coordinator.path) {
            VStack {
                coordinator.build(.home)
                    .navigationDestination(for: MyPageRoute.self) { route in
                        coordinator.build(route)
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                CommonToolbar() {
                                    coordinator.pop()
                                }
                            }
                    }
                
                Spacer()
            }
        }
    }
}

#Preview {
    MyPageCoordinatorView()
}
