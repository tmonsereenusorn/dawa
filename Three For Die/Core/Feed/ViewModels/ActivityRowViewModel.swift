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
        Task {
            await checkIfUserJoinedActivity()
        }
    }
    
    @MainActor
    func joinActivity() async throws{
        do {
            try await service.joinActivity(activity: self.activity) {
                self.activity.didJoin = true
            }
        } catch {
            print("DEBUG: Failed to join activity with error \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func checkIfUserJoinedActivity() async {
        await service.checkIfUserJoinedActivity(activity: activity) { didJoin in
            if didJoin {
                self.activity.didJoin = true
            }
        }
    }
}
