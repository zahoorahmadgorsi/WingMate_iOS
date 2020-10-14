//
//  UIButton-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import UIKit

extension UIButton {
    func setFadeInOutAnimation() {
        self.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.3,
        options: .curveLinear,
        animations: {
            self.alpha = 1
        }, completion: nil)
    }
}

