//
//  SideMenuView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct LeftSideMenuView: View {
    @State private var creatingGroup: Bool = false
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
            
            Spacer()
            
            Divider()
            
            Button {
                creatingGroup.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus.app")
                    Text("Create Group")
                    Spacer()
                }
                .foregroundColor(.black)
            }
            .popover(isPresented: $creatingGroup) {
                CreateGroupView()
            }
        }
    }
}

//struct LeftSideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftSideMenuView()
//    }
//}
