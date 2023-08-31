//
//  Color.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/29/23.
//

import SwiftUI

extension Color {
    static var theme = Theme()
}

struct Theme {
    let primaryText = Color("PrimaryTextColor")
    let background = Color("BackgroundColor")
    let secondaryBackground = Color("SecondaryBackground")
    let secondaryText = Color("SecondaryText")
    let tertiaryBackground = Color("TertiaryBackground")
}
