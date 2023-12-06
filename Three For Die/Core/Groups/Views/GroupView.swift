//
//  GroupView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 10/18/23.
//

import SwiftUI

struct GroupView: View {
    @EnvironmentObject var contentViewModel: ContentViewModel
    @Environment(\.presentationMode) var mode
    @Binding var group: Groups
    @State private var editingGroup: Bool = false
    
    private var isCurrentUserAdmin: Bool {
        guard let currentUser = contentViewModel.currentUser else { return false }
        return group.memberList?.contains(where: { $0.id == currentUser.id && ($0.groupPermissions == "Admin" || $0.groupPermissions == "Owner") }) ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
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
                
                if (isCurrentUserAdmin) {
                    Button {
                        editingGroup.toggle()
                    } label: {
                        Text("Edit Group")
                            .font(.subheadline).bold()
                            .frame(width: 120, height: 32)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
                            .foregroundColor(Color.theme.primaryText)
                    }
                }
            }
            
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    SquareGroupImageView(group: group, size: .xLarge)
                    
                    Text(group.name)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text("@\(group.handle)")
                        .foregroundColor(Color.theme.secondaryText)
                    
                    NavigationLink {
                        MemberListView(group: $group)
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(group.numMembers)")
                                .foregroundColor(.primary)
                            
                            if group.numMembers == 1 {
                                Text("member")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("members")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                }
                Spacer()
            }
            
            Spacer()
            
            
        }
        .padding()
        .navigationBarHidden(true)
        .background(Color.theme.background)
        .popover(isPresented: $editingGroup) {
            EditGroupView(group: $group)
        }
    }
}

//#Preview {
//    GroupView(group: Groups.MOCK_GROUP)
//}
