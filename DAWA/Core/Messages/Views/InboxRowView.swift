//
//  InboxRowView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct InboxRowView: View {
    let userActivity: UserActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Group image
            SquareGroupImageView(group: userActivity.activity?.group, size: .medium)
            
            // Activity and message details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(userActivity.activity?.title ?? "Error displaying activity title")
                        .font(.subheadline)
                        .fontWeight(userActivity.hasRead ? .regular : .bold)  // Bold if unread
                        .foregroundColor(Color.theme.primaryText)
                    
                    // Red dot indicator for unread messages
                    if !userActivity.hasRead {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
                
                HStack(spacing: 0) {
                    if let messageSender = userActivity.recentMessage?.user {
                        if messageSender.isCurrentUser {
                            Text("You: ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            Text("\(messageSender.username): ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text(userActivity.recentMessage?.messageText ?? "No messages yet. Start planning!")
                        .font(.subheadline)
                        .fontWeight(userActivity.hasRead ? .regular : .bold)  // Bold if unread
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
                }
            }
            
            // Timestamp and chevron icon
            HStack {
                Text(userActivity.recentMessage?.timestamp.dateValue().timeAgoDisplay() ?? "")
                    .font(.footnote)
                    .fontWeight(userActivity.hasRead ? .regular : .bold)  // Bold if unread
                    .foregroundColor(.gray)
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 72)
    }
}

// struct InboxRowView_Previews: PreviewProvider {
//     static var previews: some View {
//         InboxRowView(userActivity: UserActivity(...))  // Provide mock data here for preview
//     }
// }
