//
//  NotificationsService.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import Foundation
import Firebase

class NotificationsService {
    @Published var documentChanges = [DocumentChange]()
    
    static let shared = NotificationsService()
    
    private var firestoreListener: ListenerRegistration?
}
