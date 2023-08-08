//
//  FeedViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation


class FeedViewModel: ObservableObject {
    @Published var activities = [Activity]()
    let service = ActivityService()
    let userService = UserService()
    
    init() {
        Task {
            await fetchActivities(groupId: "iYBzqoXOHI3rSwl4y1aW")
        }
    }
    
    @MainActor
    func fetchActivities(groupId: String) async {
        await service.fetchActivities(groupId: groupId) { activities in
            self.activities = activities
            
            for i in 0 ..< activities.count {
                let uid = activities[i].userId
                Task {
                    UserService.fetchUser(withUid: uid) { user in
                        self.activities[i].user = user
                    }
                }
            }
        }
    }
}
