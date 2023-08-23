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
            await fetchActivityParticipants(activity: activity)
        }
    }
    
    @MainActor
    func fetchActivityParticipants(activity: Activity) async {
        await ActivityService.fetchActivityParticipants(activity: activity) { participants in
            self.participants = participants
        }
    }
    
    @MainActor
    func refreshActivity() async throws {
        do {
            let activityId = activity.id
            if let newActivity = try await ActivityService.fetchActivity(activityId: activityId) {
                self.activity = newActivity
                await ActivityService.checkIfUserJoinedActivity(activityId: activityId) { didJoin in
                    self.activity.didJoin = didJoin
                }
            }
        } catch {
            print("DEBUG: Failed to fetch activity with error \(error.localizedDescription)")
        }
    }
}
