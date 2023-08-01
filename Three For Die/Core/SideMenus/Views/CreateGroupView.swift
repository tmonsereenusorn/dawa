//
//  CreateGroupView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import SwiftUI

struct CreateGroupView: View {
    @State private var groupName = ""
    @ObservedObject var viewModel = CreateGroupViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Create a new group")
                .font(.title2)
            
            VStack {
                InputView(text: $groupName,
                          title: "Group Name",
                          placeholder: "Enter a name for your group")
                .padding()
            }
            
            // Cancel and Submit button
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text("Cancel")
                            .foregroundColor(.red)
                    }
                }
                Spacer ()
                
                Button {
                    Task {
                        try await viewModel.createGroup(name: groupName) { groupId in
                            groupsViewModel.currSelectedGroup = groupId
                        }
                        await groupsViewModel.fetchUserGroups()
                        await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup)
                    }
                } label: {
                    HStack {
                        Text("Create")
                            .bold()
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(.green)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
            }
            .padding()
        }
        .onReceive(viewModel.$didCreateGroup) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}

extension CreateGroupView: CreateGroupFormProtocol {
    var formIsValid: Bool {
        return !groupName.isEmpty
    }
}

//struct CreateGroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateGroupView()
//    }
//}
