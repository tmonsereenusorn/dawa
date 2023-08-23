//
//  ActivityRowViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/17/23.
//

import Foundation

class ActivityRowViewModel: ObservableObject {
    @Published var activity: Activity
    private let service = ActivityService()
    
    init(activity: Activity) {
        self.activity = activity
    }
    
    @MainActor
    func joinActivity() async throws{
        do {
            try await service.joinActivity(activityId: self.activity.id) { activity in
                self.activity = activity
                self.activity.didJoin = true
            }
        } catch {
            print("DEBUG: Failed to join activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func leaveActivity() async throws {
        do {
            try await service.leaveActivity(activity: self.activity) {
                self.activity.didJoin = false
                self.activity.numCurrent -= 1
            }
        } catch {
            print("DEBUG: Failed to leave activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func closeActivity() async throws {
        do {
            try await service.closeActivity(activity: self.activity)
        } catch {
            print("DEBUG: Failed to close activity with error \(error.localizedDescription)")
        }
    }
}
