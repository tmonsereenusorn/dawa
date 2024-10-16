//
//  NotificationRowView.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/18/24.
//

import SwiftUI

struct NotificationRowView: View {
    let notification: NotificationBase
    
    var body: some View {
        HStack {
            // Notification icon based on type
            Image(systemName: notificationIcon(for: notification.type))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(.trailing, 8)
            
            // Notification message
            notification.message
                .font(.body)
                .foregroundColor(notification.hasRead ? Color.theme.secondaryText : Color.theme.primaryText)
            
            Spacer()
            
            // Timestamp
            Text(notification.timestamp.dateValue().timeAgoDisplay())
                .font(.caption)
                .foregroundColor(Color.theme.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(notification.hasRead ? Color.clear : Color.blue.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 2)
    }
    
    private func notificationIcon(for type: NotificationType) -> String {
        switch type {
        case .activityJoin:
            return "person.crop.circle.badge.plus"
        case .activityLeave:
            return "person.crop.circle.badge.minus"
        }
    }
}

//
//
//#Preview {
//    NotificationRowView()
//}
