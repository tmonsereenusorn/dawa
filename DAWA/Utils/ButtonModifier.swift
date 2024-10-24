//
//  ButtonModifier.swift
//  DAWA
//
//  Created by Stephan Dowless on 5/18/23.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(width: 352, height: 44)
            .background(Color.theme.appTheme)
            .cornerRadius(8)
    }
}
