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
    
    var label: String {
        switch self {
        case .sport: return "Sport"
        case .game: return "Game"
        }
    }
    
    var color: Color {
        switch self {
        case .sport: return Color.blue
        case .game: return Color.red
        }
    }
    
    static func color(forLabel label: String) -> Color? {
        guard let filter = ActivityFilters.allCases.first(where: { $0.label == label }) else {
            return nil
        }
        return filter.color
    }
}
