//
//  InputView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 6/21/23.
//

import SwiftUI

struct FormInputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .foregroundColor(Color(.white))
                .fontWeight(.semibold)
                .font(.footnote)
            VStack(alignment: .leading, spacing: 0) {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(.white)
            }
        }
    }
}

//struct InputView_Previews: PreviewProvider {
//    static var previews: some View {
//        InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
//    }
//}
