//
//  UITextField-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 18/10/2020.
//

import UIKit

extension UITextField {
    func setTextFieldBorderRed() {
        self.borderWidth = 1
        self.cornerRadius = 4
        self.borderColor = UIColor.red
    }
    
    func setTextFieldBorderClear() {
        self.borderWidth = 1
        self.cornerRadius = 4
        self.borderColor = UIColor.clear
    }
}


