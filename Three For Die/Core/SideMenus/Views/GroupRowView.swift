//
//  GroupRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct GroupRowView: View {
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @Binding var group: Groups
    
    var body: some View {
        HStack {
            SquareGroupImageView(group: group, size: .medium)
            
            Text(group.name)
                
            Spacer()
            
            NavigationLink {
                GroupView(group: $group)
            } label: {
                Image(systemName: "chevron.right")
            }
            
        }
        .foregroundColor(Color.theme.primaryText)
        .padding()
        .background(groupsViewModel.currSelectedGroup?.id == group.id ? Color.theme.secondaryText : Color.theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

//#Preview {
//    GroupRowView(group: Groups.MOCK_GROUP)
//}
