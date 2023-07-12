//
//  FeedViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/12/23.
//

import Foundation

@MainActor
class FeedViewModel: ObservableObject {
    @Published var activities = [Activity]()
    let service = ActivityService()
    
    init() {
        Task {
            await fetchActivities()
        }
    }
    
    func fetchActivities() async {
        await service.fetchActivities { activities in
            self.activities = activities
            print("Fetched activities")
        }
    }
}
