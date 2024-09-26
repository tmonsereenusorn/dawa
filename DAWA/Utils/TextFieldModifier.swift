//
//  TextFieldModifier.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 5/18/23.
//

import SwiftUI

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}
