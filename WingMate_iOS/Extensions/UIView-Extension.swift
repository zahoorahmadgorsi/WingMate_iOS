//
//  UIView-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    func transformAnimation() {
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 2,
                       options: .allowUserInteraction,
                       animations: { [weak self] in
                        self?.transform = .identity
            }, completion: nil)
    }
    
    func shake(count : Float = 4,for duration : TimeInterval = 0.5,withTranslation translation : Float = 5) {

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration/TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }
    
    func addPaginationLoader(tableView: UITableView) -> UIView {
        let vw = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 34))
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.center = vw.center
        activityIndicator.frame.origin.y = 0
        activityIndicator.startAnimating()
        vw.addSubview(activityIndicator)
        return vw
    }
    
    func setViewBorderRed() {
        self.borderColor = UIColor.appThemeRedColor
    }
    
    func setViewBorderGray() {
        self.borderColor = UIColor.textFieldGrayBackgroundColor
    }
    
   
}
