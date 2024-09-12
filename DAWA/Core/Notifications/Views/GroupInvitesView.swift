//
//  GroupInvitesView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import SwiftUI

struct GroupInvitesView: View {
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = GroupInvitesViewModel()
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .resizable()
                            .frame(width: 20, height: 16)
                            .foregroundColor(Color.theme.primaryText)
                    }
                    
                    Spacer()
                    
                    Text("Group Invitations")
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.theme.primaryText)
                        .opacity(0)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
            }
            if InviteService.shared.hasInvites {
                List {
                    ForEach(viewModel.groupInvites, id: \.self) { groupInvite in
                        ZStack {
                            NavigationLink(value: groupInvite) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            
                            GroupInviteRowView(groupInvite: groupInvite)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical)
                    .padding(.trailing, 8)
                    .padding(.leading, 20)
                }
                .listStyle(PlainListStyle())
                .overlay { if !viewModel.didCompleteInitialLoad { ProgressView() } }
                .background(Color.theme.background)
            } else {
                Spacer()
                
                Text("No group invitations yet")
                    .foregroundColor(Color.theme.secondaryText)
                
                Spacer()
            }
        }
    }
}

//#Preview {
//    GroupInvitesView()
//}
