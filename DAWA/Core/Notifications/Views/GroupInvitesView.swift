import SwiftUI

struct GroupInvitesView: View {
    @Environment(\.presentationMode) var mode
    @StateObject var viewModel = GroupInvitesViewModel()
    
    var body: some View {
        VStack {
            // Custom top bar
            VStack(spacing: 0) {
                HStack {
                    // Back button
                    Button {
                        mode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .frame(width: 12, height: 20)
                            .foregroundColor(Color.theme.primaryText)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    // Title
                    Text("Group Invitations")
                        .font(.headline)
                        .foregroundColor(Color.theme.primaryText)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Invisible element to center title
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.theme.primaryText)
                        .opacity(0) // To center the title
                }
                .padding(.vertical, 10)
                
                Divider()
            }
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            // Main content
            if InviteService.shared.hasInvites {
                // List of group invites
                List {
                    ForEach(viewModel.groupInvites, id: \.self) { groupInvite in
                        ZStack {
                            NavigationLink(value: groupInvite) {
                                EmptyView()
                            }
                            .opacity(0.0)
                            
                            GroupInviteRowView(groupInvite: groupInvite)
                        }
                        .padding(8)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .overlay {
                    if !viewModel.didCompleteInitialLoad {
                        ProgressView()
                            .padding(.top, 20)
                    }
                }
            } else {
                // Empty state
                VStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Image(systemName: "envelope.badge.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.theme.secondaryText)
                        
                        Text("No group invitations yet")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.secondaryText)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
}

//#Preview {
//    GroupInvitesView()
//}
