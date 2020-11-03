//
//  EmailVerificationVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 26/10/2020.
//

import UIKit

class EmailVerificationVC: UIViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    
    var nickName = ""
    var email = ""
    
    convenience init(email: String, nickName: String) {
        self.init()
        self.nickName = nickName
        self.email = email
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelEmail.text = email
        self.labelMessage.text = "Hi \(self.nickName)! You're almost ready to start enjoying Wingmate! Simply click on the link which has been sent to your email to verify your email address."
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
        
    }

}
