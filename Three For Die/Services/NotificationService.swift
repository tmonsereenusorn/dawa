//
//  NotificationService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import Foundation
import Firebase

class NotificationService {
    static let shared = NotificationService()
    private var firestoreListener: ListenerRegistration?

    var changesStream: AsyncStream<[DocumentChange]> {
        AsyncStream { continuation in
            guard let uid = Auth.auth().currentUser?.uid else {
                continuation.finish()
                return
            }
            
            let query = FirestoreConstants.UserCollection
                .document(uid)
                .collection("notifications")
                .order(by: "timestamp", descending: true)
            
            self.firestoreListener = query.addSnapshotListener { snapshot, _ in
                guard let changes = snapshot?.documentChanges else { return }
                
                // Yield the changes to the stream
                continuation.yield(changes)
            }
            
            // When the stream is finished, remove the listener
            continuation.onTermination = { [weak self] _ in
                self?.firestoreListener?.remove()
                self?.firestoreListener = nil
            }
        }
    }
    
    func sendNotification<T: NotificationBase>(notification: T, to userIds: [String]) async throws {
        for userId in userIds {
            let notificationRef = FirestoreConstants.UserCollection
                .document(userId)
                .collection("notifications")
                .document()
            
            try await notificationRef.setData(from: notification)
        }
    }

    func reset() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
}
