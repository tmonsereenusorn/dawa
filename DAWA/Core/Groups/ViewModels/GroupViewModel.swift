import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var editingGroup: Bool = false
    @Published var showMemberRequests: Bool = false
    @Published var notificationsEnabled: Bool = false
    
    var group: Groups
    
    init(group: Groups) {
        self.group = group
    }
    
    // Function to toggle notifications
    func toggleNotifications(for groupMember: GroupMember) async {
        do {
            try await GroupService.toggleNotifications(for: groupMember.id, groupId: group.id)
            DispatchQueue.main.async {
                self.notificationsEnabled.toggle() // Update the local state on the main thread after toggling
            }
        } catch {
            print("Failed to toggle notifications: \(error)")
        }
    }
    
    // Function to update editingGroup safely from background threads
    func toggleEditingGroup() {
        DispatchQueue.main.async {
            self.editingGroup.toggle() // Ensure this update happens on the main thread
        }
    }
}
