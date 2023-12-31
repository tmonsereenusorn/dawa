//
//  InboxViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Foundation
import Combine
import Firebase

class InboxViewModel: ObservableObject {
    @Published var user: User?
    @Published var userActivities = [UserActivity]()
    
    private var cancellables = Set<AnyCancellable>()
    var didCompleteInitialLoad = false
    
    init() {
        setupSubscribers()
        InboxService.shared.observeRecentMessages()
    }
    
    private func setupSubscribers() {
        UserService.shared.$currentUser.sink { [weak self] user in
            self?.user = user
        }.store(in: &cancellables)
        
        InboxService.shared.$documentChanges.sink { [weak self] changes in
            guard let self = self, !changes.isEmpty else { return }
            
            if !self.didCompleteInitialLoad {
                print("Doing initial load")
                self.loadInitialMessages(fromChanges: changes)
            } else {
                self.updateMessages(fromChanges: changes)
            }
        }.store(in: &cancellables)
    }
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        self.userActivities = changes.compactMap{ try? $0.document.data(as: UserActivity.self) }
        
        
        for i in 0 ..< userActivities.count {
            let userActivity = userActivities[i]
            
            // Attach activity to the user's activity
            ActivityService.fetchActivity(withActivityId: userActivity.id) { [weak self] activity in
                guard let self else { return }
                
                self.userActivities[i].activity = activity
                
                // Attach most recent message to the user's activity to display preview in inbox
                if let messageId = activity.recentMessageId {
                    MessageService.fetchMessage(withMessageId: messageId, activityId: userActivity.id) { [weak self] message in
                        guard let self else { return }
                        
                        var newMessage = message
                        
                        UserService.fetchUser(withUid: message.fromUserId) { user in
                            
                            newMessage.user = user
                            
                            self.userActivities[i].recentMessage = newMessage
                        }
                    }
                }
            }
        }
        
        self.didCompleteInitialLoad = true
    }
    
    private func updateMessages(fromChanges changes: [DocumentChange]) {
        for change in changes {
            if change.type == .added {
                self.createNewConversation(fromChange: change)
            } else if change.type == .modified {
                self.updateMessagesFromExistingConversation(fromChange: change)
            } else if change.type == .removed { // if removed
                self.removeConversation(fromChange: change)
            }
        }
    }
    
    private func createNewConversation(fromChange change: DocumentChange) {
        guard var userActivity = try? change.document.data(as: UserActivity.self) else { return }
        
        let dispatchGroup = DispatchGroup()
        
        ActivityService.fetchActivity(withActivityId: userActivity.id) { [weak self] activity in
            guard let self else { return }
            
            dispatchGroup.enter()
            userActivity.activity = activity
            
            // Attach most recent message to the user's activity to display preview in inbox
            if let messageId = activity.recentMessageId {
                MessageService.fetchMessage(withMessageId: messageId, activityId: activity.id) { message in
                    var newMessage = message
                    UserService.fetchUser(withUid: message.fromUserId) { user in
                        newMessage.user = user
                        userActivity.recentMessage = newMessage
                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.userActivities.insert(userActivity, at: 0)
            }
        }
    }
    
    private func updateMessagesFromExistingConversation(fromChange change: DocumentChange) {
        guard var userActivity = try? change.document.data(as: UserActivity.self) else { return }
        guard let index = self.userActivities.firstIndex(where: {
            $0.id == userActivity.id
        }) else { return }
        
        let dispatchGroup = DispatchGroup()
        
        ActivityService.fetchActivity(withActivityId: userActivity.id) { [weak self] activity in
            guard let self else { return }
            
            dispatchGroup.enter()
            userActivity.activity = activity
            
            // Attach most recent message to the user's activity to display preview in inbox
            if let messageId = activity.recentMessageId {
                MessageService.fetchMessage(withMessageId: messageId, activityId: activity.id) { message in
                    var newMessage = message
                    UserService.fetchUser(withUid: message.fromUserId) { user in
                        newMessage.user = user
                        userActivity.recentMessage = newMessage
                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                self.userActivities.remove(at: index)
                self.userActivities.insert(userActivity, at: 0)
            }
        }
    }
    
    private func removeConversation(fromChange change: DocumentChange) {
        print("Attempting to remove conversation")
        guard let removedUserActivity = try? change.document.data(as: UserActivity.self) else { return }
        
        if let indexToRemove = userActivities.firstIndex(where: { $0.id == removedUserActivity.id }) {
            self.userActivities.remove(at: indexToRemove)
        }
    }
}
