import SwiftUI

struct ActivityView: View {
    @Environment(\.presentationMode) var mode
    @State private var editingActivity: Bool = false
    @ObservedObject var viewModel: ActivityViewModel
    @EnvironmentObject var feedViewModel: FeedViewModel
    @EnvironmentObject var groupsViewModel: GroupsViewModel
    
    // State variables for confirmation dialogs
    @State private var showJoinConfirmation: Bool = false
    @State private var showLeaveConfirmation: Bool = false
    @State private var showCloseConfirmation: Bool = false
    @State private var navigateToChat: Bool = false
    
    init(activity: Activity) {
        self.viewModel = ActivityViewModel(activity: activity)
    }
    
    var body: some View {
        ZStack {
            if let hostUser = viewModel.activity.host {
                VStack(spacing: 0) {
                    // Header and main content (Fixed)
                    VStack(spacing: 20) {
                        // Header
                        header
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        // Main Activity Content
                        VStack(spacing: 10) {
                            Text(viewModel.activity.title)
                                .foregroundColor(Color.theme.primaryText)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 5)
                            
                            activityDetails
                        }
                        .padding(.horizontal)
                    }
                    
                    // Scrollable participants section
                    ScrollView {
                        participantsSection
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Footer with buttons
                    VStack {
                        if viewModel.activity.didJoin ?? false {
                            Button(action: {
                                viewModel.markActivityAsRead()
                                navigateToChat = true
                            }) {
                                HStack {
                                    Image(systemName: "message.fill")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    Text("Go to Chat").font(.headline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color.theme.primaryText)
                                .background(Color.theme.appTheme)
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        
                        actionButton(for: hostUser)
                            .padding(.horizontal)
                        
                        Button(action: {
                            mode.wrappedValue.dismiss()
                        }) {
                            Text("Go back to activity feed")
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.footnote)
                                .underline()
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .navigationBarHidden(true)
                .blur(radius: (viewModel.isLoading || viewModel.errorMessage != nil) ? 5.0 : 0)
                .disabled(viewModel.isLoading || viewModel.errorMessage != nil)
                .onAppear {
                    Task {
                        try? await viewModel.refreshActivity()
                    }
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        viewModel.errorMessage = nil
                    }
                    .zIndex(1)
                }
            }
        }
        // Confirmation modals
        .confirmationDialog("Are you sure? Closing the activity will prevent more users from joining.", isPresented: $showCloseConfirmation, titleVisibility: .visible) {
            Button("Close Activity", role: .destructive) {
                Task {
                    try await viewModel.closeActivity()
                    try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                }
                mode.wrappedValue.dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Are you sure you want to leave?", isPresented: $showLeaveConfirmation, titleVisibility: .visible) {
            Button("Leave Activity", role: .destructive) {
                Task {
                    try await viewModel.leaveActivity()
                    try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Are you sure you want to join?", isPresented: $showJoinConfirmation, titleVisibility: .visible) {
            Button("Join Activity", role: .none) {
                Task {
                    try await viewModel.joinActivity()
                    try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .navigationDestination(isPresented: $navigateToChat) {
            ChatView(activity: viewModel.activity) // Navigate to ChatView
        }
    }
    
    private var header: some View {
        HStack {
            // Back Button
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20, height: 16)
                    .foregroundColor(Color.theme.primaryText)
            }
            
            Spacer()
            
            // Refresh Button
            Button {
                Task {
                    try? await viewModel.refreshActivity()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color.theme.primaryText)
            }
        }
    }
    
    private func actionButton(for hostUser: User) -> some View {
        Group {
            if hostUser.isCurrentUser {
                Button {
                    showCloseConfirmation = true
                } label: {
                    Text("Close activity")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .font(.headline).bold()
                }
            } else {
                if viewModel.activity.didJoin ?? false {
                    Button {
                        showLeaveConfirmation = true
                    } label: {
                        Text("Leave activity")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                            .font(.headline).bold()
                    }
                } else {
                    Button {
                        showJoinConfirmation = true
                    } label: {
                        Text("Join Activity")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.theme.appTheme)
                            .cornerRadius(10)
                            .font(.headline).bold()
                    }
                    .disabled(viewModel.activity.numRequired > 0 && viewModel.activity.numCurrent >= viewModel.activity.numRequired)
                    .opacity((viewModel.activity.numRequired > 0 && viewModel.activity.numCurrent >= viewModel.activity.numRequired) ? 0.5 : 1.0)
                }
            }
        }
        .disabled(viewModel.isLoading)
    }
    
    private var activityDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color.theme.secondaryText)
                Text(viewModel.activity.location)
                    .foregroundColor(Color.theme.secondaryText)
                    .font(.body)
                Spacer()
            }
            
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(Color.theme.secondaryText)
                Text(viewModel.activity.notes.isEmpty ? "No details provided" : viewModel.activity.notes)
                    .foregroundColor(Color.theme.secondaryText)
                    .font(.body)
                Spacer()
            }
            
            Divider()
                .background(Color.theme.secondaryText)
                .padding(.vertical, 10)
            
            if viewModel.activity.numRequired == 0 {
                Text("Participants (\(viewModel.activity.numCurrent) / ∞)")
                    .foregroundColor(Color.theme.primaryText)
                    .font(.headline)
                    .padding(.bottom, 15)
            } else {
                Text("Participants (\(viewModel.activity.numCurrent) / \(viewModel.activity.numRequired))")
                    .foregroundColor(Color.theme.primaryText)
                    .font(.headline)
                    .padding(.bottom, 15)
            }
        }
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            
            LazyVStack(spacing: 16) {
                ForEach(viewModel.participants) { participant in
                    HStack {
                        CircularProfileImageView(user: participant, size: .small)
                        Text(participant.username)
                            .foregroundColor(Color.theme.primaryText)
                            .font(.body)
                        Spacer()
                        if participant.id == viewModel.activity.userId {
                            Text("Host")
                                .foregroundColor(Color.theme.secondaryText)
                                .font(.footnote)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.theme.secondaryBackground)
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}
