//
//  ActivityView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/9/23.
//

import SwiftUI

struct ActivityView: View {
    @Environment(\.presentationMode) var mode
    @State private var activity: Activity
    @State private var editingActivity: Bool = false
    @ObservedObject var viewModel: ActivityViewModel
    
    init(activity: Activity) {
        _activity = State(initialValue: activity)
        self.viewModel = ActivityViewModel(activity: activity)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            
            HStack{
                Spacer()
                Text(activity.title)
                    .foregroundColor(.white)
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Text("Location: \(activity.location)")
                .foregroundColor(.white)
            
            Text("Details: \(activity.notes)")
                .foregroundColor(.white)
            
            Divider()
                .background(.white)
            
            Text("Participants (\(activity.numCurrent) / \(activity.numRequired))")
                .foregroundColor(.white)
            
            ScrollView() {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.participants) { participant in
                        HStack {
                            CircularProfileImageView(user: participant, size: .xxSmall)
                            Text(participant.username)
                                .foregroundColor(.white)
                                .font(.system(size: 12))
                            Spacer()
                            if participant.id == activity.userId {
                                Text("Host")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
            .refreshable {
                Task {
                    await viewModel.fetchActivityParticipants(activity: activity)
                }
            }
        }
        .padding()
        .navigationBarHidden(true)
        .background(.black)
    }
}

extension ActivityView {
    var headerView: some View {
        HStack(alignment: .top) {
            Button {
                mode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .resizable()
                    .frame(width: 20, height: 16)
                    .foregroundColor(.white)
                    .offset(x: 16, y: 12)
            }
            
            Spacer()
            
            Button {
                editingActivity.toggle()
            } label: {
                Text("Edit Activity")
                    .font(.subheadline).bold()
                    .frame(width: 120, height: 32)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 0.75))
                    .foregroundColor(.white)
            }
        }
    }
}
//
//struct ActivityView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityView()
//    }
//}
