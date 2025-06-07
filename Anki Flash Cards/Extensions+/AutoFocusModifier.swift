//
//  AutoFocusModifier.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-07.
//

import Foundation
import SwiftUI

struct AutoFocusModifier: ViewModifier {
    @FocusState private var isFocused: Bool

    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.isFocused = true
                }
            }
    }
}

extension View {
    func autoFocus() -> some View {
        self.modifier(AutoFocusModifier())
    }
}
