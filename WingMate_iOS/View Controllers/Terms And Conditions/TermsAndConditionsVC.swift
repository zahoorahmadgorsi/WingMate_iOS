//
//  TermsAndConditionsVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 03/11/2020.
//

import UIKit
import Parse
import WebKit

class TermsAndConditionsVC: BaseViewController {
    
    var user = PFUser()
    var registerPresenter = RegisterPresenter()
    
    @IBOutlet weak var webView: WKWebView!
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
     
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerPresenter.attach(vc: self)
        let url = Bundle.main.url(forResource: "tou", withExtension: "html")
        webView.load(URLRequest(url: url!))
    }

    @IBAction func agreeButtonPressed(_ sender: Any) {
        if isWrongEmailPressed {
            self.registerPresenter.wrongEmailAPI(emailWrong: oldEmail, emailNew: self.user.value(forKey: DBColumn.email) as? String ?? "")
        } else {
            self.registerPresenter.registerAPI(user: self.user)
        }
    }
    
    @IBAction func dontAgreeButtonPressed(_ sender: Any) {
        isWrongEmailPressed = false
        oldEmail = ""
        self.navigationController?.popToRootViewController(animated: true)
    }

}

extension TermsAndConditionsVC: RegisterDelegate {
    func register(isSuccess: Bool, nicknameValidationFailedMsg: String) {}
    func register(emailValidationFailedMsg: String) {}
    func register(passwordValidationFailedMsg: String) {}
    func register(validationSuccessStepThree: Bool) {}
    func register(ageValidationFailedMsg: String) {}
    
    func register(didUserRegistered: Bool, msg: String) {
        if didUserRegistered {
            self.navigationController?.pushViewController(EmailVerificationVC(user: self.user), animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
            self.showToast(message: msg)
        }
    }
    
    func register(isWrongEmailSent: Bool, msg: String) {
        if isWrongEmailSent {
            self.navigationController?.pushViewController(EmailVerificationVC(user: self.user), animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
            self.showToast(message: msg)
        }
    }
}

