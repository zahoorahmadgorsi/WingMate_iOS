//
//  BaseViewController.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Toast Methods
    func showToast(message : String) {
        let window = UIApplication.shared.keyWindow!
        //        let v = UIView(frame: window.bounds)
        //        window.addSubview(v);
        
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height-100, width: self.view.frame.width - 40, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.numberOfLines = 2
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        window.addSubview(toastLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toastLabel.removeFromSuperview()
        }
    }
    
    //MARK: -Navigation  Bar
    func setNavigationBar(title: String) {
        self.navigationController?.navigationBar.isHidden = false
        self.title = title
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        let navBar = self.navigationController?.navigationBar
        navBar?.barTintColor = .appThemeColor
        navBar?.tintColor = UIColor.buttonColor
        navBar?.isTranslucent = false
        //            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "callicon"), style: .plain, target: self, action: #selector(callTapped))
    }
    
    func setNavigationBarGradient(title: String) {
        self.navigationController?.navigationBar.isHidden = false
        self.title = title
        self.navigationController?.navigationBar.tintColor = UIColor.white
        if let navigationBar = self.navigationController?.navigationBar {
            let gradient = CAGradientLayer()
            var bounds = navigationBar.bounds
            bounds.size.height += UIApplication.shared.statusBarFrame.size.height
            gradient.frame = bounds
            gradient.colors = [UIColor.gradientStartColor.cgColor, UIColor.gradientEndColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 0)
            
            if let image = getImageFrom(gradientLayer: gradient) {
                self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
            }
        }
    }
    
    
    func setNavigationBackButtonTitleEmpty() {
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func getImageFrom(gradientLayer:CAGradientLayer) -> UIImage? {
        var gradientImage:UIImage?
        UIGraphicsBeginImageContext(gradientLayer.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
            gradientImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
        }
        UIGraphicsEndImageContext()
        return gradientImage
    }

    //MARK: -small screen devices
    func is_IPHONE_5_OR_LESS () -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            return UIScreen.main.bounds.height <= 568.0
        } else {
            return false
        }
    }

}
