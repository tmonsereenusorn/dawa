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
    
    init(activity: Activity) {
        self.viewModel = ActivityViewModel(activity: activity)
    }
    
    var body: some View {
        ZStack {
            if let hostUser = viewModel.activity.host {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            backButton
                            
                            Spacer()
                        }
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
                    .padding(.bottom, 100) // Add extra padding to make space for the button
                }
                .navigationBarHidden(true)
                .background(Color.theme.background)
                .blur(radius: viewModel.isLoading ? 3.0 : 0)
                .disabled(viewModel.isLoading)
                
                // Button at the bottom
                VStack {
                    Spacer()
                    actionButton(for: hostUser)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
        }
    }
    
    private var backButton: some View {
        Button {
            mode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "arrow.left")
                .resizable()
                .frame(width: 20, height: 16)
                .foregroundColor(Color.theme.primaryText)
        }
    }
    
    private func actionButton(for hostUser: User) -> some View {
        Group {
            if hostUser.isCurrentUser {
                Button {
                    Task {
                        try await viewModel.closeActivity()
                        try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                    }
                    mode.wrappedValue.dismiss()
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
                        Task {
                            try await viewModel.leaveActivity()
                            try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                        }
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
                        Task {
                            try await viewModel.joinActivity()
                            try await feedViewModel.fetchActivities(groupId: groupsViewModel.currSelectedGroup!.id)
                        }
                    } label: {
                        Text("Join Activity")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.theme.appTheme)
                            .cornerRadius(10)
                            .font(.headline).bold()
                    }
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
            Text("Participants (\(viewModel.activity.numCurrent) / \(viewModel.activity.numRequired))")
                .foregroundColor(Color.theme.primaryText)
                .font(.headline)
            
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
