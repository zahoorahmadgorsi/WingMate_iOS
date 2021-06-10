//
//  DecideLoginRegisterVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 17/10/2020.
//

import UIKit
import SVProgressHUD

class PreLoginVC: BaseViewController {

    //MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SVProgressHUD.dismiss()
        if didPressedLoginNowOnEmailVerification {
            didPressedLoginNowOnEmailVerification = false
            self.navigationController?.pushViewController(LoginVC(), animated: false)
        }
        if APP_MANAGER.session != nil {
            let vc = Utilities.shared.getViewController(identifier: TabBarVC.className, storyboardType: .main) as! TabBarVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - Button Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(LoginVC(), animated: true)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(TutorialVC(), animated: true)
    }
}
