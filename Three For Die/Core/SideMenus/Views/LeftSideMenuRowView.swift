//
//  SideMenuRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct LeftSideMenuRowView: View {
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 48, height: 48)
            
            Text("Stanford University")
            
            Spacer()
            
            Image(systemName: "ellipsis")
        }
        .padding()
    }
}

//struct LeftSideMenuRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftSideMenuRowView()
//    }
//}
