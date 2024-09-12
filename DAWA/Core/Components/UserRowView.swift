//
//  UserRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/9/23.
//

import SwiftUI

struct UserRowView: View {
    let user: User
    let textColor: Color
    
    var body: some View {
        HStack {
            CircularProfileImageView(user: user, size: .xxSmall)
            Text(user.username)
                .foregroundColor(textColor)
                .font(.system(size: 12))
        }
    }
}

//struct UserRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRowView()
//    }
//}
