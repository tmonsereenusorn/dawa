import SwiftUI

struct InboxView: View {
    @EnvironmentObject var viewModel: InboxViewModel
    @Binding var showLeftMenu: Bool
    @Binding var showRightMenu: Bool
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    @State private var navigateToChat = false
    @State private var selectedActivity: Activity? = nil
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        withAnimation { showLeftMenu.toggle() }
                    } label: {
                        SquareGroupImageView(group: groupsViewModel.currSelectedGroup, size: .xSmall)
                    }
                    
                    Spacer()
                    
                    Text("Inbox")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        withAnimation { showRightMenu.toggle() }
                    } label: {
                        CircularProfileImageView(user: viewModel.user, size: .xSmall)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
            }
            
            if viewModel.didCompleteInitialLoad {
                List {
                    ForEach(viewModel.userActivities, id: \.self) { userActivity in
                        ZStack {
                            NavigationLink(destination: {
                                if let activity = userActivity.activity {
                                    ChatView(activity: activity)
                                        .onAppear {
                                            if let activityId = userActivity.activity?.id {
                                                viewModel.markAsRead(activityId: activityId)
                                            }
                                        }
                                }
                            }) {
                                InboxRowView(userActivity: userActivity, currTime: viewModel.currentTime)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.vertical)
                    .padding(.trailing, 8)
                    .padding(.leading, 20)
                    
                }
                .listStyle(PlainListStyle())
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(PushNotificationHandler.shared.$tappedActivityId) { activityId in
            if let activityId = activityId {
                if let userActivity = viewModel.userActivities.first(where: { $0.activity?.id == activityId }) {
                    selectedActivity = userActivity.activity
                    navigateToChat = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToChat) {
            if let activity = selectedActivity {
                ChatView(activity: activity)
                    .onAppear {
                        if let activityId = selectedActivity?.id {
                            viewModel.markAsRead(activityId: activityId)
                        }
                    }
            }
        }
    }
}
