//
//  ChatViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/12/23.
//

import Foundation

class ChatViewModel: ObservableObject {
    @Published var messageText = ""
    @Published var messages = [Message]()
    let activity: Activity
    
    init(activity: Activity) {
        self.activity = activity
        observeMessages()
    }
    
    func sendMessage() {
        MessageService.sendMessage(messageText, toActivity: activity)
    }
    
    func observeMessages() {
        MessageService.observeMessages(activityId: activity.id) { messages in
            self.messages.append(contentsOf: messages)
        }
    }
}
