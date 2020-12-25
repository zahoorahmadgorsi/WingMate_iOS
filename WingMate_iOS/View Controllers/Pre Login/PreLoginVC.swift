//
//  DecideLoginRegisterVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 17/10/2020.
//

import UIKit

class PreLoginVC: BaseViewController {

    //MARK: - View Controller Life Cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if didPressedLoginNowOnEmailVerification {
            didPressedLoginNowOnEmailVerification = false
            self.navigationController?.pushViewController(LoginVC(), animated: false)
        }
        if APP_MANAGER.session != nil {
            self.navigationController?.pushViewController(DashboardVC(), animated: false)
        }
    }
    
    //MARK: - Button Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(UploadPhotoVideoVC(), animated: true)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(TutorialVC(), animated: true)
    }
}
