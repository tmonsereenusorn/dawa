//
//  GroupInviteRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import SwiftUI

struct GroupInviteRowView: View {
    let groupInvite: GroupInvite
    @StateObject var viewModel = GroupInviteRowViewModel()
    
    var body: some View {
        if let group = groupInvite.group {
            HStack {
                SquareGroupImageView(group: group, size: .medium)
                
                Text("\(group.name)")
                    .foregroundColor(Color.theme.primaryText)
                
                Spacer()
                
                Button("Confirm") {
                    Task {
                        try await viewModel.acceptGroupInvitation(groupInvite: groupInvite)
                    }
                }
                .padding()
                .foregroundColor(.white) // Text color
                .background(Color.blue) // System blue background
                .cornerRadius(10) // Rounded corners
                
                Button("Delete") {
                    Task {
                        try await viewModel.deleteGroupInvitation(groupInvite: groupInvite)
                    }
                }
                .padding()
                .foregroundColor(.white) // Text color
                .background(Color.theme.secondaryBackground) // System blue background
                .cornerRadius(10) // Rounded corners
            }
        }
    }
}

//#Preview {
//    GroupInviteRowView()
//}
