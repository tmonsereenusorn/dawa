//
//  NotificationsViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import Foundation
import Combine
import Firebase

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var user: User?
    @Published var notifications = [NotificationBase]()
    @Published var initialLoad = true
    
    var hasUnreadNotifications: Bool {
        notifications.contains { !$0.hasRead }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribers()
        startListeningForChanges()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .assign(to: \.user, on: self)
            .store(in: &cancellables)
    }
    
    private func startListeningForChanges() {
        Task {
            for await changes in NotificationService.shared.changesStream {
                if self.initialLoad {
                    notifications = await processNotificationsInParallel(changes)
                    self.objectWillChange.send()
                    self.initialLoad = false
                } else {
                    await handleNewNotifications(changes)
                }
            }
        }
    }

    private func processNotificationsInParallel(_ changes: [DocumentChange]) async -> [NotificationBase] {
        var notifications = [NotificationBase]()
        
        await withTaskGroup(of: NotificationBase?.self) { group in
            for change in changes where change.type == .added {
                group.addTask { await self.processNotification(change) }
            }
            
            for await notification in group {
                if let notification = notification {
                    notifications.append(notification)
                }
            }
        }
        
        notifications.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
        
        return notifications
    }
    
    private func processNotification(_ change: DocumentChange) async -> NotificationBase? {
        guard let typeString = change.document.data()["type"] as? String,
              let notificationType = NotificationType(rawValue: typeString) else { return nil }
        
        do {
            var notification: NotificationBase
            let userId: String
            let activityId: String
            
            switch notificationType {
            case .activityJoin:
                notification = try change.document.data(as: ActivityJoinNotification.self)
                userId = (notification as! ActivityJoinNotification).joinedByUserId
                activityId = (notification as! ActivityJoinNotification).activityId
            case .activityLeave:
                notification = try change.document.data(as: ActivityLeaveNotification.self)
                userId = (notification as! ActivityLeaveNotification).leftByUserId
                activityId = (notification as! ActivityLeaveNotification).activityId
            }
            
            notification.user = try await UserService.fetchUser(uid: userId)
            notification.activity = try await ActivityService.fetchActivity(activityId: activityId)
            return notification
        } catch {
            print("DEBUG: Failed to fetch user or decode \(notificationType)Notification - \(error)")
            return nil
        }
    }

    private func handleNewNotifications(_ changes: [DocumentChange]) async {
        for change in changes where change.type == .added {
            if let notification = await processNotification(change) {
                notifications.insert(notification, at: 0)
                self.objectWillChange.send()
            }
        }
    }
    
    func markAllNotificationsAsRead() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        await withTaskGroup(of: Void.self) { group in
            for (index, notification) in notifications.enumerated() where !notification.hasRead {
                if let notificationId = notification.id {
                    group.addTask {
                        do {
                            // Safely update the notification's read status on the main thread
                            await MainActor.run {
                                self.notifications[index].hasRead = true
                            }
                            
                            // Update the notification in Firestore
                            try await FirestoreConstants.UserCollection.document(uid)
                                .collection("notifications")
                                .document(notificationId)
                                .updateData(["hasRead": true])
                        } catch {
                            print("Failed to mark notification as read: \(error)")
                        }
                    }
                }
            }
        }
    }


}

