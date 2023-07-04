//
//  AddActivityViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/4/23.
//

import Foundation
import SwiftUI

enum AddActivityViewModel: Int, CaseIterable {
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
}
