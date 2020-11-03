//
//  TermsAndConditionsVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 03/11/2020.
//

import UIKit
import Parse

class TermsAndConditionsVC: UIViewController {
    
    var user = PFUser()
    var registerPresenter = RegisterPresenter()
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerPresenter.attach(vc: self)
    }

    @IBAction func agreeButtonPressed(_ sender: Any) {
        self.registerPresenter.registerAPI(user: PFUser())
    }
    
    @IBAction func dontAgreeButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}

extension TermsAndConditionsVC: RegisterDelegate {
    func register(isSuccess: Bool, nicknameValidationFailedMsg: String) {}
    func register(emailValidationFailedMsg: String) {}
    func register(passwordValidationFailedMsg: String) {}
    func register(validationSuccessStepThree: Bool) {}
    
    func register(didUserRegistered: Bool, msg: String) {
        if didUserRegistered {
            self.navigationController?.pushViewController(EmailVerificationVC(user: self.user), animated: true)
        } else {
            Utilities.shared.showErrorBanner(msg: msg)
        }
    }
}

