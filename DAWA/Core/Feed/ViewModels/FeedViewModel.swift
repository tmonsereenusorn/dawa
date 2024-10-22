//
//  FeedViewModel.swift
//  DAWA
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

    @MainActor
    func fetchActivities(groupId: String) async throws {
        self.activities = []

        let fetchedActivities = try await ActivityService.fetchActivities(groupId: groupId)

        var updatedActivities = [Activity]()

        await withTaskGroup(of: Activity?.self) { group in
            for fetchedActivity in fetchedActivities {
                group.addTask {
                    do {
                        var activity = fetchedActivity
                        let uid = activity.userId
                        let activityId = activity.id
                        
                        if let user = try? await UserService.fetchUser(uid: uid) {
                            activity.host = user
                        }
                        
                        activity.didJoin = await ActivityService.checkIfUserJoinedActivity(activityId: activityId)
                        
                        return activity
                    } catch {
                        print("Failed to fetch details for activity \(fetchedActivity.id): \(error.localizedDescription)")
                        return nil
                    }
                }
            }

            for await updatedActivity in group {
                if let activity = updatedActivity {
                    updatedActivities.append(activity)
                }
            }
        }

        // Sort activities by timestamp after fetching and updating
        self.activities = updatedActivities.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
    }

}
