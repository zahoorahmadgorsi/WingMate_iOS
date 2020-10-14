//
//  UILabel-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import UIKit

extension UILabel {
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
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
