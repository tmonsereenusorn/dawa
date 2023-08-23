//
//  FeedViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation


class FeedViewModel: ObservableObject {
    @Published var activities = [Activity]()
    let userService = UserService()
    
    init() {
        Task {
            await fetchActivities(groupId: "iYBzqoXOHI3rSwl4y1aW")
        }
    }
    
    @MainActor
    func fetchActivities(groupId: String) async {
        await ActivityService.fetchActivities(groupId: groupId) { activities in
            self.activities = activities
            
            for i in 0 ..< activities.count {
                let uid = activities[i].userId
                let activityId = activities[i].id
                Task {
                    if let user = try? await UserService.fetchUser(uid: uid) {
                        self.activities[i].user = user
                    }
                    await ActivityService.checkIfUserJoinedActivity(activityId: activityId) { didJoin in
                        self.activities[i].didJoin = didJoin
                    }
                }
            }
        }
    }
}
