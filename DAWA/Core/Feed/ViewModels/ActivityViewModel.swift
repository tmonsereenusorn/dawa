//
//  ActivityViewModel.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 8/9/23.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activity: Activity
    @Published var participants = [User]()
    @Published var isLoading = false
    
    init(activity: Activity) {
        self.activity = activity
    }
    
    @MainActor
    func fetchActivityParticipants() async {
        await ActivityService.fetchActivityParticipants(activity: activity) { participants in
            self.participants = participants
        }
    }
    
    @MainActor
    func refreshActivity() async throws {
        do {
            isLoading = true
            let activityId = activity.id
            if let newActivity = try await ActivityService.fetchActivity(activityId: activityId) {
                activity.numCurrent = newActivity.numCurrent
                activity.didJoin = await ActivityService.checkIfUserJoinedActivity(activityId: activityId)
            }
            await fetchActivityParticipants()
            isLoading = false
        } catch {
            print("DEBUG: Failed to fetch activity with error \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    @MainActor
    func joinActivity() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await ActivityService.joinActivity(activityId: self.activity.id) {
                
            }
            try await refreshActivity()
        } catch {
            print("DEBUG: Failed to join activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func leaveActivity() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await ActivityService.leaveActivity(activity: self.activity)
            try await refreshActivity()
        } catch {
            print("DEBUG: Failed to leave activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func closeActivity() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await ActivityService.closeActivity(activity: self.activity)
        } catch {
            print("DEBUG: Failed to close activity with error \(error.localizedDescription)")
        }
    }
}
