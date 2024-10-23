//
//  DateExtension.swift
//  DAWA
//
//  Created by Tee Monsereenusorn on 2/19/23.
//

import Foundation

extension Date {
    func timeAgoDisplay(from _: Date = Date()) -> String {
        let currTime = Date() // Always use the current date
        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: currTime)!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: currTime)!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: currTime)!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: currTime)!
        
        if self > minuteAgo {
            let diff = calendar.dateComponents([.second], from: self, to: currTime).second ?? 0
            return "\(diff) sec ago"
        } else if self > hourAgo {
            let diff = calendar.dateComponents([.minute], from: self, to: currTime).minute ?? 0
            return "\(diff) min ago"
        } else if self > dayAgo {
            let diff = calendar.dateComponents([.hour], from: self, to: currTime).hour ?? 0
            return "\(diff) hrs ago"
        } else if self > weekAgo {
            let diff = calendar.dateComponents([.day], from: self, to: currTime).day ?? 0
            if diff == 1 {
                return "1 day ago"
            } else {
                return "\(diff) days ago"
            }
        } else {
            let diff = calendar.dateComponents([.weekOfYear], from: self, to: currTime).weekOfYear ?? 0
            if diff == 1 {
                return "1 week ago"
            } else {
                return "\(diff) weeks ago"
            }
        }
    }
}
