//
//  SideMenuView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct LeftSideMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Groups")
                .font(.title2).bold()
                .padding(.leading)
            Divider()
            
            ScrollView {
                LazyVStack {
                    ForEach(0 ... 2, id: \.self) { _ in
                        LeftSideMenuRowView()
                    }
                }
            }
        }
    }
}

//struct LeftSideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftSideMenuView()
//    }
//}