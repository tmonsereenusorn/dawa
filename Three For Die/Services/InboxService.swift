//
//  InboxService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/15/23.
//

import Foundation
import Firebase

class InboxService {
    @Published var documentChanges = [DocumentChange]()
    static let shared = InboxService()
    private var firestoreListener: ListenerRegistration?
    
    // need to call this thru shared instance to setup the observer
    func observeRecentMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.UserCollection
            .document(uid)
            .collection("user-activities")
            .order(by: "timestamp", descending: true)
        
        self.firestoreListener = query.addSnapshotListener { snapshot, _ in
            guard let changes = snapshot?.documentChanges else { return }
            
            self.documentChanges = changes
        }
    }
    
    func reset() {
        self.firestoreListener?.remove()
        self.firestoreListener = nil
        self.documentChanges.removeAll()
    }
}
