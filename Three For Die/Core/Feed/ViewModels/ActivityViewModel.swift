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
        Task { await fetchActivityParticipants(activity: activity)}
    }
    
    func fetchActivityParticipants(activity: Activity) async {
        await activityService.fetchActivityParticipants(activity: activity) { participants in
            self.participants = participants
        }
    }
}
