//
//  PaymentVC.swift
//  WingMate_iOS
//
//  Created by mac on 16/05/2021.
//

import UIKit
import Parse
import SVProgressHUD

class PaymentVC: BaseViewController {
    
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var cstHeightBackButton: NSLayoutConstraint!
    @IBOutlet weak var cstTopBackButton: NSLayoutConstraint!
    
    var isTrialExpired = false
    
    convenience init(isTrialExpired: Bool) {
        self.init()
        self.isTrialExpired = isTrialExpired
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonBack.isHidden = self.isTrialExpired ? true : false
        self.cstHeightBackButton.constant = self.isTrialExpired ? 0 : 50
        self.cstTopBackButton.constant = self.isTrialExpired ? 0 : 20
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func payNowButtonPressed(_ sender: Any) {
        if PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false {
            self.showToast(message: "You're already a paid user")
        } else {
            PFUser.current()?.setValue(true, forKey: DBColumn.isPaidUser)
            SVProgressHUD.show()
            ParseAPIManager.updateUserObject() { (success) in
                SVProgressHUD.dismiss()
                if success {
                    APP_MANAGER.session = PFUser.current()
//                    self.showToast(message: "Congrats on becoming a paid user")
                    
                    let vc = CongratsVC(isPhotosVideoUploadedFlow: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showToast(message: "Failed to update to paid user")
                }
            } onFailure: { (error) in
                self.showToast(message: error)
            }
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        ParseAPIManager.logoutUser { (success) in
            APP_MANAGER.session = nil
//            self.navigationController?.popToRootViewController(animated: true)
            let vc = PreLoginVC()
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APP_DELEGATE.window?.rootViewController = navigationController
        } onFailure: { (error) in
            self.showToast(message: error)
        }
    }
    

}
