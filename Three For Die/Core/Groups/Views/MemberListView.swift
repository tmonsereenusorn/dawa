//
//  MemberListView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 10/30/23.
//

import SwiftUI

struct MemberListView: View {
    @StateObject var viewModel = MemberListViewModel()
    @Binding var group: Groups
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Button {
                    mode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .frame(width: 20, height: 16)
                        .foregroundColor(Color.theme.primaryText)
                        .offset(x: 16, y: 12)
                }
                
                Spacer()
            }

            Text("Members")
            
            // Group members
            Text("Number of Members:  \(group.numMembers)")
                .foregroundColor(Color.theme.primaryText)
            
            if let members = group.memberList {
                ScrollView() {
                    LazyVStack(spacing: 16) {
                        ForEach(members) { member in
                            HStack {
                                CircularProfileImageView(user: member, size: .xxSmall)
                                Text(member.username)
                                    .foregroundColor(Color.theme.primaryText)
                                    .font(.system(size: 12))
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .refreshable {
                    Task {
                        try await viewModel.refreshGroup(groupId: group.id)
                        if let newGroup = viewModel.group {
                            self.group = viewModel.group!
                        }
                    }
                }
            }
            
            Spacer()
        }
        .navigationBarHidden(true)
        .background(Color.theme.background)
    }
}

//#Preview {
//    MemberListView()
//}
