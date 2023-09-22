//
//  ProfileImageSize.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/7/23.
//

import Foundation

enum ProfileImageSize {
    case xxxSmall
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xLarge
    
    var dimension: CGFloat {
        switch self {
        case .xxxSmall:
            return 20
        case .xxSmall:
            return 28
        case .xSmall:
            return 32
        case .small:
            return 40
        case .medium:
            return 48
        case .large:
            return 60
        case .xLarge:
            return 88
        }
    }
}
