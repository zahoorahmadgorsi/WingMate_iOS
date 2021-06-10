//
//  UIViewController-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlertOK(_ title: String, message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertTwoButtons(_ title: String, message: String, successHandler: ((UIAlertAction) -> Void)?, failureHandler: ((UIAlertAction) -> Void)?) {
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Yes", style: .default, handler: successHandler)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: failureHandler)
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        //        alertController.view.tintColor = UIConfig.appColor
        present(alertController, animated: true, completion: nil)
    }
    
    func showOnScreenLabel(vw: UIView, msg: String) {
        vw.layoutIfNeeded()
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: vw.frame.width, height: vw.frame.height))
        lbl.text = msg
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 14)
        lbl.textAlignment = .center
        lbl.textColor = UIColor.black
        lbl.tag = 24321
        vw.addSubview(lbl)
    }
    
    func removeOnScreenLabel(vw: UIView) {
        for i in vw.subviews {
            if let lbl = i.viewWithTag(24321) as? UILabel {
                lbl.removeFromSuperview()
                break
            }
        }
    }
    
}
