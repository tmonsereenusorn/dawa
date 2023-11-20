//
//  InboxRowView.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/11/23.
//

import SwiftUI

struct InboxRowView: View {
    let userActivity: UserActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            SquareGroupImageView(group: userActivity.activity?.group, size: .medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(userActivity.activity?.title ?? "Error displaying activity title")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.primaryText)
                
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
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .frame(maxWidth: UIScreen.main.bounds.width - 100, alignment: .leading)
                }
            }
            
            HStack {
                Text(userActivity.recentMessage?.timestamp.dateValue().timeAgoDisplay() ?? "")
                
                Image(systemName: "chevron.right")
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .frame(height: 72)
    }
}

//struct InboxRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        InboxRowView()
//    }
//}
