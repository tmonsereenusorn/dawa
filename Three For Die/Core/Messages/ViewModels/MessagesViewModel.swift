//
//  MessagesViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/24/23.
//

import Foundation

class MessagesViewModel: ObservableObject {
    @Published var userActivities = [Activity]()
    private let activityService = ActivityService()
    private let userService = UserService()
    
    init() {
        Task {
            await fetchUserActivities()
        }
    }
    
    @MainActor
    func fetchUserActivities() async {
        await activityService.fetchUserActivities { activities in
            self.userActivities = activities
            
            for i in 0 ..< activities.count {
                let uid = activities[i].userId
                Task {
                    await self.userService.fetchUser(withUid: uid) { user in
                        self.userActivities[i].user = user
                    }
                }
            }
        }
    }
}
