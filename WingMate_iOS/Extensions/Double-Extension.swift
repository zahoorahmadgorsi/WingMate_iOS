//
//  Double-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
