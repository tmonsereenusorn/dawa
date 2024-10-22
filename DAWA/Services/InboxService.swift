//
//  InboxService.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Foundation
import Firebase

class InboxService {
    static let shared = InboxService()
    private var firestoreListener: ListenerRegistration?
    
    var changesStream: AsyncStream<[DocumentChange]> {
        AsyncStream { continuation in
            // Setup Firestore listener
            guard let uid = Auth.auth().currentUser?.uid else {
                continuation.finish()
                return
            }
            
            let query = FirestoreConstants.UserCollection
                .document(uid)
                .collection("user-activities")
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
    
    func reset() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
    }
}

