//
//  MessageService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/12/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct MessageService {
    
    @MainActor
    static func fetchMessage(withMessageId messageId: String, activityId: String) async throws -> Message? {
        do {
            let snapshot = try await FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document(messageId).getDocument()
            return try snapshot.data(as: Message.self)
        } catch {
            print("DEBUG: Failed to fetch message with error \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchMessage(withMessageId messageId: String, activityId: String, completion: @escaping(Message) -> Void) {
        FirestoreConstants.ActivitiesCollection.document(activityId).collection("messages").document(messageId).getDocument() { snapshot, _ in
            guard let message = try? snapshot?.data(as: Message.self) else {
                print("DEBUG: Failed to map message")
                return
            }
            completion(message)
        }
    }
}
