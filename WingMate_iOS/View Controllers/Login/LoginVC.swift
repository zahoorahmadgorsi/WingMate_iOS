//
//  LoginVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/10/2020.
//

import UIKit
import Parse

class LoginVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var viewValidationEmail: UIView!
    @IBOutlet weak var labelValidationEmail: UILabel!
    @IBOutlet weak var viewValidationPassword: UIView!
    @IBOutlet weak var labelValidationPassword: UILabel!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonShowPassword: UIButton!
    @IBOutlet weak var cstHeightEmailValidationView: NSLayoutConstraint!
    @IBOutlet weak var cstHeightPasswordValidationView: NSLayoutConstraint!
    @IBOutlet weak var cstTopPasswordValidationView: NSLayoutConstraint!
    @IBOutlet weak var imageViewCheckBox: UIImageView!
    var shouldShowPassword = false
    var loginPresenter = LoginPresenter()
    var isRememberMe = false
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginPresenter.attach(vc: self)
        self.setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.textFieldEmail.text = APP_MANAGER.userEmail ?? ""
        self.textFieldPassword.text = APP_MANAGER.userPassword ?? ""
//        self.textFieldEmail.text = "muneebrehman758@gmail.com"
//        self.textFieldPassword.text = "qqqqqq"
        if APP_MANAGER.userEmail ?? "" != "" {
            self.shouldShowPassword = true
            self.imageViewCheckBox.image = UIImage(named: "checked")
        }
    }
    
    //MARK: - Helper Methods
    func setLayout() {
        self.cstHeightEmailValidationView.constant = 0
        self.cstHeightPasswordValidationView.constant = 0
        self.cstTopPasswordValidationView.constant = 0
    }
    
    func resetValidationViews() {
        self.textFieldEmail.backgroundColor = UIColor.textFieldGrayBackgroundColor
        self.textFieldPassword.backgroundColor = UIColor.textFieldGrayBackgroundColor
        self.cstHeightEmailValidationView.constant = 0
        self.cstHeightPasswordValidationView.constant = 0
        self.cstTopPasswordValidationView.constant = 0
        self.labelValidationEmail.text = ""
        self.labelValidationPassword.text = ""
        self.textFieldEmail.setTextFieldBorderClear()
        self.textFieldPassword.setTextFieldBorderClear()
    }

    //MARK: - Button Actions
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.pushViewController(ForgotPasswordVC(), animated: true)
    }
    
    @IBAction func showPasswordButtonPressed(_ sender: Any) {
        self.shouldShowPassword = !self.shouldShowPassword
        self.textFieldPassword.isSecureTextEntry = self.shouldShowPassword ? false : true
        let img = self.shouldShowPassword ? UIImage(named: "showpassword") : UIImage(named: "hidepassword")
        self.buttonShowPassword.setImage(img, for: .normal)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.loginPresenter.checkForValidations(email: self.textFieldEmail.text ?? "", password: self.textFieldPassword.text ?? "")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rememberMeButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.isRememberMe = !self.isRememberMe
        self.imageViewCheckBox.image = self.isRememberMe ? UIImage(named: "checked") : UIImage(named: "unchecked")
        //save email & password to defaults
    }
}

extension LoginVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.resetValidationViews()
        textField.backgroundColor = UIColor.appThemeYellowColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.backgroundColor = UIColor.textFieldGrayBackgroundColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension LoginVC: LoginDelegate {
    func login(emailValidationFailedMsg: String) {
        self.labelValidationEmail.text = emailValidationFailedMsg
        self.cstHeightEmailValidationView.constant = 16
        self.textFieldEmail.setTextFieldBorderRed()
    }
    
    func login(passwordValidationFailedMsg: String) {
        self.labelValidationPassword.text = passwordValidationFailedMsg
        self.cstHeightPasswordValidationView.constant = 16
        self.cstTopPasswordValidationView.constant = 12
        self.textFieldPassword.setTextFieldBorderRed()
    }
    
    func login(didUserLoggedIn: Bool, msg: String) {
        
        if didUserLoggedIn {
            let isMediaApproved = PFUser.current()?.value(forKey: DBColumn.isMediaApproved) as? Bool ?? false
            let accountStatus = PFUser.current()?.value(forKey: DBColumn.accountStatus) as? Int ?? 0
            let isEmailVerified = PFUser.current()?.value(forKey: DBColumn.emailVerified) as? Bool ?? false
            
            if accountStatus == UserAccountStatus.rejected.rawValue {
                self.showAlertOK(APP_NAME, message: ValidationStrings.kAccountRejected)
            } else if isEmailVerified == false {
                self.showToast(message: ValidationStrings.kVerifyEmail)
            } else {
                self.rememberMe()
                let vc = Utilities.shared.getViewController(identifier: TabBarVC.className, storyboardType: .main) as! TabBarVC
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            self.showToast(message: msg)
        }
    }
    
    func rememberMe() {
        if self.isRememberMe {
            APP_MANAGER.userEmail = self.textFieldEmail.text!
            APP_MANAGER.userPassword = self.textFieldPassword.text!
        } else {
            APP_MANAGER.userEmail = ""
            APP_MANAGER.userPassword = ""
        }
    }
    
}
