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
            await fetchActivities()
        }
    }
    
    @MainActor
    func fetchActivities() async {
        await service.fetchActivities { activities in
            self.activities = activities
            
            for i in 0 ..< activities.count {
                let uid = activities[i].userId
                Task {
                    await self.userService.fetchUser(withUid: uid) { user in
                        self.activities[i].user = user
                    }
                }
            }
        }
    }
}
