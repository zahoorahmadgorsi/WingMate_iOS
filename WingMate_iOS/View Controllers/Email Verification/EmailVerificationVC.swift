//
//  EmailVerificationVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 26/10/2020.
//

import UIKit
import Parse

class EmailVerificationVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    
    var emailVerificationPresenter = EmailVerificationPresenter()
    var user = PFUser()
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isWrongEmailPressed = false
        oldEmail = ""
        
        self.emailVerificationPresenter.attach(vc: self)
        let email = self.user.value(forKey: "email") as? String ?? ""
        let nickName = self.user.value(forKey: "nick") as? String ?? ""
        
        self.labelEmail.text = email
        self.labelMessage.text = "Hi \(nickName)! You're almost ready to start enjoying Wingmate! Simply click on the link which has been sent to your email to verify your email address."
        
        self.emailVerificationPresenter.pushNotification(title: APP_NAME, msg: "A new user has just registered to \(APP_NAME)")
    }
    
    //MARK: - Button Actions
    @IBAction func loginNowButtonPressed(_ sender: Any) {
        didPressedLoginNowOnEmailVerification = true
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func wrongEmailButtonPressed(_ sender: Any) {
        isWrongEmailPressed = true
        oldEmail = self.user.value(forKey: DBColumn.email) as? String ?? ""
        self.navigationController?.popToViewController ((self.navigationController?.viewControllers[3]) as! RegisterStepTwoVC, animated: true)
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        self.emailVerificationPresenter.resendEmailAPI(email: self.user.value(forKey: DBColumn.email) as? String ?? "")
    }

}

extension EmailVerificationVC: EmailVerificationDelegate {
    func emailVerification(didResendEmailSuccessfully: Bool, msg: String) {
        self.showToast(message: msg)
    }
}
