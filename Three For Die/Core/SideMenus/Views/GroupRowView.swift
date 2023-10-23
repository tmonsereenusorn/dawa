//
//  GroupRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/3/23.
//

import SwiftUI

struct GroupRowView: View {
    @ObservedObject var viewModel: GroupRowViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    init(group: Groups) {
        self.viewModel = GroupRowViewModel(group: group)
    }
    
    var body: some View {
        HStack {
            SquareGroupImageView(group: viewModel.group, size: .medium)
            
            Text(viewModel.group.name)
                
            Spacer()
            
            NavigationLink {
                GroupView(group: $viewModel.group)
            } label: {
                Image(systemName: "chevron.right")
            }
            
        }
        .foregroundColor(Color.theme.primaryText)
        .padding()
        .background(groupsViewModel.currSelectedGroup == viewModel.group.id ? Color.theme.secondaryText : Color.theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

//#Preview {
//    GroupRowView(group: Groups.MOCK_GROUP)
//}
