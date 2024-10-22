//
//  ActivityFilters.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/4/23.
//

import Foundation
import SwiftUI

enum ActivityFilters: Int, CaseIterable {
    case sport
    case game
    case social
    case food
    case study
    case art
    case others
    
    var label: String {
        switch self {
        case .sport: return "Sport"
        case .game: return "Game"
        case .social: return "Social"
        case .food: return "Food & Drink"
        case .study: return "Study"
        case .art: return "Art & Music"
        case .others: return "Others"
        }
    }
    
    var color: Color {
        switch self {
        case .sport: return Color.blue           // Blue for activity and energy
        case .game: return Color.red             // Red for excitement and fun
        case .social: return Color.orange        // Orange for social and warm interactions
        case .food: return Color.green           // Green for food and nature
        case .study: return Color.yellow         // Yellow for knowledge and learning
        case .art: return Color.pink             // Pink for creativity and artistic expression
        case .others: return Color.purple        // Purple as a neutral category
        }
    }
    
    static func color(forLabel label: String) -> Color? {
        guard let filter = ActivityFilters.allCases.first(where: { $0.label == label }) else {
            return nil
        }
        return filter.color
    }
}
