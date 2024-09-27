//
//  ActivityView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/9/23.
//

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
    
    init(activity: Activity) {
        self.viewModel = ActivityViewModel(activity: activity)
    }
    
    var body: some View {
        ZStack {
            if let hostUser = viewModel.activity.host {
                ScrollView {
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
                            
                            activityDetails
                            
                            Divider()
                                .background(Color.theme.secondaryText)
                            
                            // Activity Participants
                            participantsSection
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }
                .navigationBarHidden(true)
                .background(Color.theme.background)
                .blur(radius: viewModel.isLoading ? 3.0 : 0)
                .disabled(viewModel.isLoading)
                .onAppear {
                    Task {
                        try? await viewModel.refreshActivity()
                    }
                }
                
                VStack {
                    Spacer()
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
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
        // Confirmation modals
        .confirmationDialog("Are you sure?", isPresented: $showCloseConfirmation, titleVisibility: .visible) {
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
    }
    
    private var header: some View {
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
        }
    }
    
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.activity.numRequired == 0 {
                Text("Participants (\(viewModel.activity.numCurrent) / ∞)")
                    .foregroundColor(Color.theme.primaryText)
                    .font(.headline)
            } else {
                Text("Participants (\(viewModel.activity.numCurrent) / \(viewModel.activity.numRequired))")
                    .foregroundColor(Color.theme.primaryText)
                    .font(.headline)
            }
            
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
            .padding(.horizontal)
        }
    }
}

//
//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView()
//    }
//}
