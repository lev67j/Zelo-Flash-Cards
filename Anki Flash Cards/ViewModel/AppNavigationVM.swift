//
//  AppNavigationVM.swift
//  Zelo AI
//
//  Created by Lev Vlasov on 2025-08-16.
//

import SwiftUI

final class AppNavigationVM: ObservableObject {
    @Published var selectedTab: TabName = .home
    @Published var cardsTextForChat = ""
    @Published var isTabBarVisible = true
}
