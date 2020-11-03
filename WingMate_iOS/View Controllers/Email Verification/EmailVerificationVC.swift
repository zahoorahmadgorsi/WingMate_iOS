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
        
        self.emailVerificationPresenter.attach(vc: self)
        let email = self.user.value(forKey: "email") as? String ?? ""
        let nickName = self.user.value(forKey: "nick") as? String ?? ""
        
        self.labelEmail.text = email
        self.labelMessage.text = "Hi \(nickName)! You're almost ready to start enjoying Wingmate! Simply click on the link which has been sent to your email to verify your email address."
    }
    
    //MARK: - Button Actions
    @IBAction func loginNowButtonPressed(_ sender: Any) {
        didPressedLoginNowOnEmailVerification = true
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @IBAction func wrongEmailButtonPressed(_ sender: Any) {
        self.navigationController?.popToViewController ((self.navigationController?.viewControllers[3]) as! RegisterStepThreeVC, animated: true)
    }
    
    @IBAction func sendEmailAgainButtonPressed(_ sender: Any) {
        self.emailVerificationPresenter.resendEmailAPI(user: self.user)
    }

}

extension EmailVerificationVC: EmailVerificationDelegate {
    func emailVerification(didResendEmailSuccessfully: Bool) {
        if didResendEmailSuccessfully {
            self.showToast(message: ValidationStrings.kEmailResent)
        }
    }
}
