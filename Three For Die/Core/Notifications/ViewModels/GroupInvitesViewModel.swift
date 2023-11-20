//
//  GroupInvitesViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 11/16/23.
//

import Foundation
import Combine
import Firebase

class GroupInvitesViewModel: ObservableObject {
    @Published var groupInvites = [GroupInvite]()
    private var cancellables = Set<AnyCancellable>()
    @Published var didCompleteInitialLoad = false
    @Published var hasInvites = false
    
    init() {
        setupSubscribers()
        InviteService.shared.observeGroupInvites()
    }
    
    private func setupSubscribers() {
        InviteService.shared.$documentChanges.sink { [weak self] changes in
            guard let self = self, !changes.isEmpty else { return }
            
            if !self.didCompleteInitialLoad {
                self.loadInitialGroupInvites(fromChanges: changes)
            } else {
                self.updateGroupInvites(fromChanges: changes)
            }
        }.store(in: &cancellables)
    }
    
    private func loadInitialGroupInvites(fromChanges changes: [DocumentChange]) {
        self.groupInvites = changes.compactMap{ try? $0.document.data(as: GroupInvite.self) }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        for i in 0 ..< groupInvites.count {
            dispatchGroup.enter()
            let groupInvite = groupInvites[i]
            
            // Attach group to the user's group invite
            GroupService.fetchGroup(withGroupId: groupInvite.forGroupId) { [weak self] group in
                guard let self else { return }
                
                self.groupInvites[i].group = group
                
                dispatchGroup.leave()
            }
        }
        dispatchGroup.leave()
        
        dispatchGroup.notify(queue: .main) {
            print("Completed initial load")
            self.didCompleteInitialLoad = true
        }
    }
    
    private func updateGroupInvites(fromChanges changes: [DocumentChange]) {
        for change in changes {
            if change.type == .added {
                self.addNewGroupInvite(fromChange: change)
            } else if change.type == .removed { // if removed
                self.removeGroupInvite(fromChange: change)
            }
        }
    }
    
    private func addNewGroupInvite(fromChange change: DocumentChange) {
        guard var groupInvite = try? change.document.data(as: GroupInvite.self) else { return }
        
        
        GroupService.fetchGroup(withGroupId: groupInvite.forGroupId) { [weak self] group in
            guard let self else { return }
            
            groupInvite.group = group
            
            self.groupInvites.insert(groupInvite, at: 0)
        }
    }
    
    private func removeGroupInvite(fromChange change: DocumentChange) {
        guard let removedGroupInvite = try? change.document.data(as: GroupInvite.self) else { return }
        
        if let indexToRemove = groupInvites.firstIndex(where: { $0.id == removedGroupInvite.id }) {
            self.groupInvites.remove(at: indexToRemove)
        }
    }
}
