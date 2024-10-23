//
//  InboxViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Foundation
import Firebase

@MainActor
class InboxViewModel: ObservableObject {
    @Published var user: User?
    @Published var userActivities = [UserActivity]()
    @Published var didCompleteInitialLoad = false
    @Published var currentTime = Date()
    
    var hasUnreadMessages: Bool {
        userActivities.contains { !$0.hasRead }
    }
    
    init() {
        setupSubscribers()
        startListeningForChanges()
        startUpdatingCurrentTime()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser
            .assign(to: &$user)
    }
    
    private func startListeningForChanges() {
        Task {
            for await changes in InboxService.shared.changesStream {
                if !didCompleteInitialLoad {
                    print("Doing initial load")
                    await loadInitialMessages(fromChanges: changes)
                } else {
                    await processChanges(changes)
                }
            }
        }
    }
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) async {
        do {
            self.userActivities = try changes.compactMap { try $0.document.data(as: UserActivity.self) }
            await updateUserActivities()
            await MainActor.run {
                self.didCompleteInitialLoad = true
            }
        } catch {
            print("Failed to load initial messages: \(error.localizedDescription)")
        }
    }
    
    private func processChanges(_ changes: [DocumentChange]) async {
        for change in changes {
            switch change.type {
            case .added:
                await createOrUpdateConversation(fromChange: change, shouldInsert: true)
            case .modified:
                await createOrUpdateConversation(fromChange: change, shouldInsert: false)
            case .removed:
                await removeConversation(fromChange: change)
            }
        }
    }
    
    private func createOrUpdateConversation(fromChange change: DocumentChange, shouldInsert: Bool) async {
        do {
            var userActivity = try change.document.data(as: UserActivity.self)
            
            if let activity = try await ActivityService.fetchActivity(activityId: userActivity.id) {
                userActivity.activity = activity
                
                if let messageId = activity.recentMessageId {
                    if var message = try await MessageService.fetchMessage(withMessageId: messageId, activityId: activity.id) {
                        message.user = try await UserService.fetchUser(uid: message.fromUserId)
                        userActivity.recentMessage = message
                    }
                }
            }
            
            if shouldInsert {
                self.userActivities.insert(userActivity, at: 0)
            } else if let index = self.userActivities.firstIndex(where: { $0.id == userActivity.id }) {
                self.userActivities[index] = userActivity
            }
            
            self.userActivities.sort {
                let date1 = $0.recentMessage?.timestamp.dateValue() ?? $0.activity?.timestamp.dateValue() ?? Date.distantPast
                let date2 = $1.recentMessage?.timestamp.dateValue() ?? $1.activity?.timestamp.dateValue() ?? Date.distantPast
                return date1 > date2
            }
            
            self.objectWillChange.send()
        } catch {
            print("Failed to create or update conversation: \(error.localizedDescription)")
        }
    }
    
    private func removeConversation(fromChange change: DocumentChange) async {
        do {
            let removedUserActivity = try change.document.data(as: UserActivity.self)
            
            if let indexToRemove = userActivities.firstIndex(where: { $0.id == removedUserActivity.id }) {
                self.userActivities.remove(at: indexToRemove)
            }
        } catch {
            print("Failed to remove conversation: \(error.localizedDescription)")
        }
    }
    
    private func updateUserActivities() async {
        await withTaskGroup(of: (Int, UserActivity?).self) { group in
            for i in 0..<userActivities.count {
                group.addTask {
                    do {
                        var updatedActivity = await self.userActivities[i]
                        
                        if let activity = try await ActivityService.fetchActivity(activityId: updatedActivity.id) {
                            updatedActivity.activity = activity
                            
                            if let messageId = activity.recentMessageId {
                                if var message = try await MessageService.fetchMessage(withMessageId: messageId, activityId: updatedActivity.id) {
                                    message.user = try await UserService.fetchUser(uid: message.fromUserId)
                                    updatedActivity.recentMessage = message
                                }
                            }
                        }
                        
                        return (i, updatedActivity)
                    } catch {
                        print("Failed to update user activities: \(error.localizedDescription)")
                        return (i, nil)
                    }
                }
            }
            
            for await (index, updatedActivity) in group {
                if let updatedActivity = updatedActivity {
                    await MainActor.run {
                        self.userActivities[index] = updatedActivity
                    }
                }
            }
        }
    }
    
    private func startUpdatingCurrentTime() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor in
                self.currentTime = Date()
            }
        }
    }

    
    func markAsRead(activityId: String) {
        if let index = userActivities.firstIndex(where: { $0.id == activityId }) {
            userActivities[index].hasRead = true
            ChatService.markAsRead(activityId: activityId)
        }
    }
}
