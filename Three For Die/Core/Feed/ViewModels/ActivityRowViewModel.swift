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
}
