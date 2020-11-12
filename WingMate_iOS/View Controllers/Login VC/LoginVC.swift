//
//  LoginVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/10/2020.
//

import UIKit

class LoginVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var viewValidationEmail: UIView!
    @IBOutlet weak var labelValidationEmail: UILabel!
    @IBOutlet weak var viewValidationPassword: UIView!
    @IBOutlet weak var labelValidationPassword: UILabel!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var cstHeightEmailValidationView: NSLayoutConstraint!
    @IBOutlet weak var cstHeightPasswordValidationView: NSLayoutConstraint!
    var shouldShowPassword = true
    var loginPresenter = LoginPresenter()
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginPresenter.attach(vc: self)
        self.setLayout()
        self.textFieldEmail.text = "danishnaeem57@gmail.com"
        self.textFieldPassword.text = "1234567890"
    }
    
    //MARK: - Helper Methods
    func setLayout() {
        self.cstHeightEmailValidationView.constant = 0
        self.cstHeightPasswordValidationView.constant = 0
    }
    
    func resetValidationViews() {
        self.textFieldEmail.backgroundColor = UIColor.textFieldGrayBackgroundColor
        self.textFieldPassword.backgroundColor = UIColor.textFieldGrayBackgroundColor
        self.cstHeightEmailValidationView.constant = 0
        self.cstHeightPasswordValidationView.constant = 0
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
        self.textFieldPassword.isSecureTextEntry = self.shouldShowPassword
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.loginPresenter.checkForValidations(email: self.textFieldEmail.text ?? "", password: self.textFieldPassword.text ?? "")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
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
        self.textFieldPassword.setTextFieldBorderRed()
    }
    
    func login(didUserLoggedIn: Bool, msg: String) {
        if didUserLoggedIn {
            self.navigationController?.pushViewController(QuestionnairesVC(), animated: true)
        } else {
            Utilities.shared.showErrorBanner(msg: msg)
        }
    }
    
}
