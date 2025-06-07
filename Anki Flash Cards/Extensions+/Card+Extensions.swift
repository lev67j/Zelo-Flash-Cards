//
//  Card+Extensions.swift
//  Flash Card
//
//  Created by Lev Vlasov on 2025-04-09.
//

import Foundation
import SwiftUI
import CoreData

extension Card {
    var lastGrade: CardGrade {
        get {
            let rawValue = lastGradeRaw ?? "new"
            print("Card \(frontText ?? "unknown") - lastGradeRaw: \(rawValue), parsed to: \(CardGrade(rawValue: rawValue) ?? .new)")
            return CardGrade(rawValue: rawValue) ?? .new
        }
        set {
            lastGradeRaw = newValue.rawValue
            print("Card \(frontText ?? "unknown") - Setting lastGrade to: \(newValue.rawValue)")
        }
    }
}

// Определение enum CardGrade
enum CardGrade: String, CaseIterable {
    case new, again, hard, good, easy
    
    var displayName: String {
        switch self {
        case .new: return "New"
        case .again: return "Again"
        case .hard: return "Hard"
        case .good: return "Good"
        case .easy: return "Easy"
        }
    }
    
    var color: Color {
        switch self {
        case .new: return Color.purple
        case .again: return Color.red
        case .hard: return Color.orange
        case .good: return Color.green
        case .easy: return Color.blue
        }
    }
}
