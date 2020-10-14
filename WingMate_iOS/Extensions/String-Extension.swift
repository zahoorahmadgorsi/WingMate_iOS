//
//  String-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation

extension String {
    
    func condensingWhitespace() -> String { //example "  my   name is  " -> "my name is"
        return self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func getDate(format:String, defaultFormat: String = "yyyy-MM-dd HH:mm:ss Z") -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = defaultFormat
            dateFormatter.timeZone = TimeZone.current
            if let dateAdded = dateFormatter.date(from: self ) {
                dateFormatter.dateFormat = format
                return dateFormatter.string(from: dateAdded)
            }
            return ""
        }
    
}
