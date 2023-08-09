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
    private let activityService = ActivityService()
    
    init(activity: Activity) {
        self.activity = activity
        Task {
            await fetchActivityParticipants(activity: activity)
        }
    }
    
    @MainActor
    func fetchActivityParticipants(activity: Activity) async {
        await activityService.fetchActivityParticipants(activity: activity) { participants in
            self.participants = participants
        }
    }
    
    @MainActor
    func refreshActivity() async throws {
        do {
            if let newActivity = try await ActivityService.fetchActivity(activity: activity) {
                self.activity = newActivity
            }
        } catch {
            print("DEBUG: Failed to fetch activity with error \(error.localizedDescription)")
        }
    }
}
