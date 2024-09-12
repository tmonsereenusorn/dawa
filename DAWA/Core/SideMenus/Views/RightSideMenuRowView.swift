//
//  RightSideMenuRowView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 7/7/23.
//

import SwiftUI

struct RightSideMenuRowView: View {
    let option: RightSideMenuRow
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: option.imageName)
                .foregroundColor(color)
            
            Text(option.title)
                .font(.subheadline)
                .foregroundColor(color)
            
            Spacer()
        }
        .frame(height: 40)
        .padding(.horizontal)
    }
}

//struct RightSideMenuRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        RightSideMenuRowView()
//    }
//}
