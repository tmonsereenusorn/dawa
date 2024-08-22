//
//  NotificationRowView.swift
//  Three For Die
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
            Text(notification.message)
                .font(.body)
                .foregroundColor(notification.hasRead ? .secondary : .primary)
            
            Spacer()
            
            // Timestamp
            Text(notification.timestamp.dateValue(), style: .time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .background(notification.hasRead ? Color.clear : Color.blue.opacity(0.1))
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
