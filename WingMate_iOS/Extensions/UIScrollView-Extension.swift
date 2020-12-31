//
//  UIScrollView-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 29/12/2020.
//

import UIKit

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}
