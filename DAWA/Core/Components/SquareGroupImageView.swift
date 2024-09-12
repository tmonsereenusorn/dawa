//
//  SquareGroupImageView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 10/18/23.
//

import SwiftUI
import Kingfisher

struct SquareGroupImageView: View {
    var group: Groups?
    let size: ProfileImageSize
    
    var body: some View {
        if let imageUrl = group?.groupImageUrl {
            KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            Image(systemName: "person.crop.square.fill")
                .resizable()
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(Color(.systemGray4))
                
        }
    }
}

//#Preview {
//    SquareGroupImageView(group: Groups.MOCK_GROUP, size: .large)
//}
