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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.checkAccountStatus()
    }
    
    @IBAction func payNowButtonPressed(_ sender: Any) {
        if APP_MANAGER.session?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false {
            self.showToast(message: "You're already a paid user")
        } else {
            PFUser.current()?.setValue(true, forKey: DBColumn.isPaidUser)
            SVProgressHUD.show()
            ParseAPIManager.updateUserObject() { (success) in
                SVProgressHUD.dismiss()
                if success {
                    APP_MANAGER.session = PFUser.current()
                    self.showToast(message: "Congrats on becoming a paid user")
                    self.dismiss(animated: true) {
                        let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
                        vc.hidesBottomBarWhenPushed = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
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
    
    override func checkAccountStatus() {
        self.getAccountStatus(completion: { (status) in
            if status == UserAccountStatus.rejected.rawValue {
                self.logoutUser()
                return
            }
        })
    }

}
