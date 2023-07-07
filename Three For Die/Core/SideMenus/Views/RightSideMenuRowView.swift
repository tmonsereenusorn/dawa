//
//  RightSideMenuRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/7/23.
//

import SwiftUI

struct RightSideMenuRowView: View {
    let option: RightSideMenuViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: option.imageName)
                .foregroundColor(.gray)
            
            Text(option.title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
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
