//
//  InboxViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Foundation
import Combine
import Firebase

@MainActor
class InboxViewModel: ObservableObject {
    @Published var user: User?
    @Published var userActivities = [UserActivity]()
    
    private var cancellables = Set<AnyCancellable>()
    var didCompleteInitialLoad = false
    
    init() {
        setupSubscribers()
        startListeningForChanges()
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
                    loadInitialMessages(fromChanges: changes)
                } else {
                    processChanges(changes)
                }
            }
        }
    }
    
    private func loadInitialMessages(fromChanges changes: [DocumentChange]) {
        self.userActivities = changes.compactMap { try? $0.document.data(as: UserActivity.self) }
        updateUserActivities()
        didCompleteInitialLoad = true
    }
    
    private func processChanges(_ changes: [DocumentChange]) {
        for change in changes {
            switch change.type {
            case .added:
                createOrUpdateConversation(fromChange: change, shouldInsert: true)
            case .modified:
                createOrUpdateConversation(fromChange: change, shouldInsert: false)
            case .removed:
                removeConversation(fromChange: change)
            }
        }
    }
    
    private func createOrUpdateConversation(fromChange change: DocumentChange, shouldInsert: Bool) {
        guard var userActivity = try? change.document.data(as: UserActivity.self) else { return }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ActivityService.fetchActivity(withActivityId: userActivity.id) { [weak self] activity in
            guard let self = self else { return }
            userActivity.activity = activity
            
            if let messageId = activity.recentMessageId {
                dispatchGroup.enter()
                MessageService.fetchMessage(withMessageId: messageId, activityId: activity.id) { message in
                    var newMessage = message
                    UserService.fetchUser(withUid: message.fromUserId) { user in
                        newMessage.user = user
                        userActivity.recentMessage = newMessage
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if shouldInsert {
                self.userActivities.insert(userActivity, at: 0)
            } else {
                if let index = self.userActivities.firstIndex(where: { $0.id == userActivity.id }) {
                    self.userActivities[index] = userActivity
                }
            }
            
            self.userActivities.sort {
                let date1 = $0.recentMessage?.timestamp.dateValue() ?? $0.activity?.timestamp.dateValue() ?? Date.distantPast
                let date2 = $1.recentMessage?.timestamp.dateValue() ?? $1.activity?.timestamp.dateValue() ?? Date.distantPast
                return date1 > date2
            }
            
            self.objectWillChange.send()
        }
    }
    
    private func removeConversation(fromChange change: DocumentChange) {
        guard let removedUserActivity = try? change.document.data(as: UserActivity.self) else { return }
        
        if let indexToRemove = userActivities.firstIndex(where: { $0.id == removedUserActivity.id }) {
            self.userActivities.remove(at: indexToRemove)
        }
    }
    
    private func updateUserActivities() {
        for i in 0..<userActivities.count {
            let userActivity = userActivities[i]
            
            ActivityService.fetchActivity(withActivityId: userActivity.id) { [weak self] activity in
                guard let self = self else { return }
                self.userActivities[i].activity = activity
                
                if let messageId = activity.recentMessageId {
                    MessageService.fetchMessage(withMessageId: messageId, activityId: userActivity.id) { [weak self] message in
                        guard let self = self else { return }
                        
                        var newMessage = message
                        UserService.fetchUser(withUid: message.fromUserId) { user in
                            newMessage.user = user
                            self.userActivities[i].recentMessage = newMessage
                        }
                    }
                }
            }
        }
    }
}
