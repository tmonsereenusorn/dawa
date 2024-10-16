import SwiftUI

struct FeedView: View {
    @Binding var showLeftMenu: Bool
    @Binding var showRightMenu: Bool
    @State private var addingEvent: Bool = false
    @EnvironmentObject var contentViewModel: ContentViewModel
    @EnvironmentObject var viewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        if let user = contentViewModel.currentUser {
            ZStack {
                VStack {
                    VStack(spacing: 0) {
                        HStack {
                            Button {
                                withAnimation { showLeftMenu.toggle() }
                            } label: {
                                SquareGroupImageView(group: groupsViewModel.currSelectedGroup, size: .xSmall)
                            }
                            
                            Spacer()
                            
                            VStack {
                                Text("Activity Feed")
                                    .font(.headline)
                                
                                if let groupName = groupsViewModel.currSelectedGroup?.name {
                                    Text(groupName)
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.secondaryText)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation { showRightMenu.toggle() }
                            } label: {
                                CircularProfileImageView(user: user, size: .xSmall)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        Divider()
                    }
                    
                    ZStack(alignment: .bottomTrailing) {
                        List {
                            SearchBar(text: $viewModel.searchText)
                                .focused($isSearchFieldFocused)
                            
                            if viewModel.filteredActivities.isEmpty {
                                Text("No activities found")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(viewModel.filteredActivities) { activity in
                                    ZStack {
                                        NavigationLink(value: activity) {
                                            EmptyView()
                                        }
                                        .opacity(0.0)
                                        
                                        ActivityRowView(activity: activity)
                                    }
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .refreshable {
                            Task {
                                try await viewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                            }
                        }
                        .navigationDestination(for: Activity.self, destination: { activity in
                            ActivityView(activity: activity)
                        })
                        
                        Button() {
                            addingEvent.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: UIScreen.main.bounds.width / 8, height: UIScreen.main.bounds.width / 8)
                                .foregroundColor(Color.theme.appTheme)
                        }
                        .background(Color.theme.background)
                        .clipShape(Circle())
                        .padding()
                        .popover(isPresented: $addingEvent) {
                            AddActivityView(user: user)
                        }
                    }
                }
                
                // Overlay that only appears when keyboard is up
                if isSearchFieldFocused {
                    Color.black.opacity(0.01) // Almost completely transparent
                        .ignoresSafeArea()
                        .onTapGesture {
                            isSearchFieldFocused = false
                            UIApplication.shared.dismissKeyboard()
                        }
                }
            }
            .onChange(of: groupsViewModel.currSelectedGroup?.id) { newGroupId in
                if let groupId = newGroupId {
                    Task {
                        try? await viewModel.fetchActivities(groupId: groupId)
                    }
                }
            }
        } else {
            ProgressView("Loading Feed...")
        }
    }
}
