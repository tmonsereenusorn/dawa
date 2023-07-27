//
//  GroupsView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct GroupsView: View {
    @State private var creatingGroup: Bool = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var viewModel: GroupsViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Groups")
                .font(.title2).bold()
                .padding(.leading)
            Divider()
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.groups) { group in
                        Button {
                            viewModel.currSelectedGroup = group.id!
                        } label: {
                            GroupRowView(group: group)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .refreshable {
                Task {
                    await viewModel.fetchUserGroups()
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
        .padding(10)
    }
}

//struct LeftSideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        LeftSideMenuView()
//    }
//}
