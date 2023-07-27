//
//  GroupRowViewModel.swift
//  Three For Die
//
//  Created by Tee Monsereenusorn on 7/27/23.
//

import Foundation

class GroupRowViewModel: ObservableObject {
    @Published var group: Groups
    private let service = GroupService()
    
    init(group: Groups) {
        self.group = group
        
    }
}
