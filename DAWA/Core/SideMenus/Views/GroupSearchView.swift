import SwiftUI

struct GroupSearchView: View {
    @StateObject var viewModel = GroupSearchViewModel()
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    var body: some View {
        ZStack {
            Color.theme.appBackground
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            VStack {
                searchBar
                    .padding(.horizontal)
                
                if viewModel.groups.isEmpty {
                    Text("No groups found")
                        .foregroundColor(Color.theme.secondaryText)
                        .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.groups) { group in
                                groupRow(for: group)
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .navigationTitle("Search for Groups")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Extract the search bar
    var searchBar: some View {
        TextField("Search for group handle", text: $viewModel.searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(height: 44)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(8)
            .onChange(of: viewModel.searchText) { newValue in
                Task {
                    do {
                        try await viewModel.searchForGroups()
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
    }
    
    // Extract the group row for cleaner code
    func groupRow(for group: Groups) -> some View {
        VStack {
            HStack {
                SquareGroupImageView(group: group, size: .small)

                VStack(alignment: .leading) {
                    Text(group.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.primaryText)
                    
                    Text("@\(group.handle)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.secondaryText)
                }
                
                Spacer()
                
                if groupsViewModel.groups.contains(where: { $0.id == group.id }) {
                    Text("Joined")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else if viewModel.pendingRequests.contains(group.id) {
                    Text("Request Sent")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                } else {
                    Button("Request to Join") {
                        Task {
                            do {
                                try await GroupService.requestToJoinGroup(groupId: group.id)
                                await viewModel.fetchPendingRequests()
                            } catch {
                                print("Error: \(error)")
                            }
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.appTheme)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            Divider()
                .padding(.leading, 40)
        }
        .padding(.leading)
    }
}
