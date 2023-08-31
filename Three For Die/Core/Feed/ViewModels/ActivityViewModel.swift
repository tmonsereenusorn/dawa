//
//  ActivityViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 8/9/23.
//

import Foundation

class ActivityViewModel: ObservableObject {
    @Published var activity: Activity
    @Published var participants = [User]()
    
    init(activity: Activity) {
        self.activity = activity
        Task {
            await fetchActivityParticipants()
        }
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
            let activityId = activity.id
            if var newActivity = try await ActivityService.fetchActivity(activityId: activityId) {
                activity.numCurrent = newActivity.numCurrent
                activity.didJoin = await ActivityService.checkIfUserJoinedActivity(activityId: activityId)
            }
            
        } catch {
            print("DEBUG: Failed to fetch activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func joinActivity() async throws{
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
        do {
            try await ActivityService.leaveActivity(activity: self.activity) {
                
            }
            try await refreshActivity()
        } catch {
            print("DEBUG: Failed to leave activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func closeActivity() async throws {
        do {
            try await ActivityService.closeActivity(activity: self.activity)
        } catch {
            print("DEBUG: Failed to close activity with error \(error.localizedDescription)")
        }
    }
}
