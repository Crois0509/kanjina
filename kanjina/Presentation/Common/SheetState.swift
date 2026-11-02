//
//  SheetState.swift
//  kanjina
//
//  Created by 장상경 on 5/16/26.
//

import SwiftUI
import Combine

final class SheetState: ObservableObject {
    @Published var isShowSheet: Bool = false
    @Published var kanji: Kanji? = nil
    @Published var isSuccessful: Bool? = nil
    @Published var isBookmarked: Bool = false
}
