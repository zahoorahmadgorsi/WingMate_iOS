//
//  NSObject-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
}

