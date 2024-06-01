//
//  Date+Utils.swift
//  Instagram
//
//  Created by Terry Jason on 2024/5/26.
//

import Foundation

extension Date {
    
    func timeAgoToDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = K.DateText.second
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = K.DateText.min
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = K.DateText.hour
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = K.DateText.day
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = K.DateText.week
        } else {
            quotient = secondsAgo / month
            unit = K.DateText.month
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? K.String.empty : K.DateText.s) \(K.DateText.ago)"
    }
    
}
