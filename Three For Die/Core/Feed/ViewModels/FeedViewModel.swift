//
//  FeedViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation


class FeedViewModel: ObservableObject {
    @Published var activities = [Activity]()
    @Published var searchText = ""
    
    var filteredActivities: [Activity] {
        if searchText.isEmpty {
            return activities
        } else {
            return activities.filter { activity in
                return activity.title.lowercased().contains(searchText.lowercased()) ||
                        activity.category.lowercased().contains(searchText.lowercased()) ||
                        activity.location.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    init() {
        Task {
            try await fetchActivities(groupId: "iYBzqoXOHI3rSwl4y1aW")
        }
    }
    
    @MainActor
    func fetchActivities(groupId: String) async throws {
        self.activities = []
        
        let fetchedActivities = try await ActivityService.fetchActivities(groupId: groupId)
        for i in 0 ..< fetchedActivities.count {
            var activity = fetchedActivities[i]
            let uid = activity.userId
            let activityId = activity.id
            if let user = try? await UserService.fetchUser(uid: uid) {
                activity.user = user
            }
            activity.didJoin = await ActivityService.checkIfUserJoinedActivity(activityId: activityId)
            self.activities.append(activity)
        }
//        self.activities = try await ActivityService.fetchActivities(groupId: groupId)
//
//        for i in 0 ..< activities.count {
//            let uid = activities[i].userId
//            let activityId = activities[i].id
//            if let user = try? await UserService.fetchUser(uid: uid) {
//                self.activities[i].user = user
//            }
//            self.activities[i].didJoin = await ActivityService.checkIfUserJoinedActivity(activityId: activityId)
//        }
    }
}
