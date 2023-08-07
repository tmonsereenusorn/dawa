//
//  CircularProfileImageView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/7/23.
//

import SwiftUI
import Kingfisher

struct CircularProfileImageView: View {
    var user: User?
    let size: ProfileImageSize
    
    var body: some View {
        if let imageUrl = user?.profileImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
                .foregroundColor(Color(.systemGray4))
        }
    }
}

//struct CircularProfileImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircularProfileImageView(user: dev.user, size: .large)
//    }
//}
