//
//  UILabel-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import UIKit

extension UILabel {
    
    func setFadeInOutAnimation() {
        self.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0.05,
        options: .curveLinear,
        animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func transformAndBounceLabelAnimation(springDamping: CGFloat, velocity: CGFloat, scale: CGFloat) {
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: velocity,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.transform = .identity
            }, completion: nil)
    }
    
}
