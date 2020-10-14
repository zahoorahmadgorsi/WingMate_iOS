//
//  DateTime-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation

extension Date {
    
    var string: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }
    
    func getStringDate(format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func yearAgo(noOfYear: Int) -> Date? {
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var offsetComponents: DateComponents = DateComponents()
        offsetComponents.year = -(noOfYear)
        return gregorian.date(byAdding: offsetComponents, to: self)
    }
    
    func yearAfter(noOfYear: Int) -> Date? {
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var offsetComponents: DateComponents = DateComponents()
        offsetComponents.year = noOfYear
        return gregorian.date(byAdding: offsetComponents, to: self)
    }
    
    func monthAgo(noOfMonth: Int) -> Date? {
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var offsetComponents: DateComponents = DateComponents()
        offsetComponents.month = -(noOfMonth)
        return gregorian.date(byAdding: offsetComponents, to: self)
    }
    
    func monthAfter(noOfMonth: Int) -> Date? {
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var offsetComponents: DateComponents = DateComponents()
        offsetComponents.month = noOfMonth
        return gregorian.date(byAdding: offsetComponents, to: self)
    }
    
    func daysAgo(noOfDays: Int) -> Date? {
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var offsetComponents: DateComponents = DateComponents()
        offsetComponents.day = -(noOfDays)
        return gregorian.date(byAdding: offsetComponents, to: self)
    }
    
    func daysAfter(noOfDays: Int) -> Date? {
        let gregorian: Calendar = Calendar(identifier: .gregorian)
        var offsetComponents: DateComponents = DateComponents()
        offsetComponents.day = noOfDays
        return gregorian.date(byAdding: offsetComponents, to: self)
    }
    
}

