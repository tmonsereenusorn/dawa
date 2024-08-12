//
//  NotificationsViewModel.swift
//  Three For Die
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
    
    private var cancellables = Set<AnyCancellable>()
    var didCompleteInitialLoad = false
    
    init() {
        setupSubscribers()
        startListeningForChanges()
    }
    
    private func setupSubscribers() {
        // Subscribe to the current user changes
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.user = user
        }.store(in: &cancellables)
    }
    
    private func startListeningForChanges() {
        Task {
            for await changes in NotificationService.shared.changesStream {
                for change in changes where change.type == .added {
                    await handleAddedNotification(change)
                }
            }
        }
    }
    
    private func handleAddedNotification(_ change: DocumentChange) async {
        guard let typeString = change.document.data()["type"] as? String,
              let notificationType = NotificationType(rawValue: typeString) else {
            return
        }
        
        switch notificationType {
        case .activityJoin:
            await handleActivityJoinNotification(change)
        case .activityLeave:
            await handleActivityLeaveNotification(change)
        }
    }
    
    private func handleActivityJoinNotification(_ change: DocumentChange) async {
        do {
            var notification = try change.document.data(as: ActivityJoinNotification.self)
            let user = try await UserService.fetchUser(uid: notification.joinedByUserId)
            notification.user = user
            addNotification(notification)
        } catch {
            print("DEBUG: Failed to fetch user or decode ActivityJoinNotification - \(error)")
        }
    }
    
    private func handleActivityLeaveNotification(_ change: DocumentChange) async {
        do {
            var notification = try change.document.data(as: ActivityLeaveNotification.self)
            let user = try await UserService.fetchUser(uid: notification.leftByUserId)
            notification.user = user
            addNotification(notification)
        } catch {
            print("DEBUG: Failed to fetch user or decode ActivityLeaveNotification - \(error)")
        }
    }
    
    private func addNotification(_ notification: NotificationBase) {
        notifications.insert(notification, at: 0)
        self.objectWillChange.send()
    }
}
