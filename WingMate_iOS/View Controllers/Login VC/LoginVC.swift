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
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
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
        
    }
    
    @IBAction func showPasswordButtonPressed(_ sender: Any) {
        self.shouldShowPassword = !self.shouldShowPassword
        self.textFieldPassword.isSecureTextEntry = self.shouldShowPassword
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        if self.textFieldEmail.text == "" {
            self.labelValidationEmail.text = ValidationStrings.kEnterEmail
            self.cstHeightEmailValidationView.constant = 16
            self.textFieldEmail.setTextFieldBorderRed()
        } else {
            if self.textFieldEmail.text!.isValidEmail == false {
                self.labelValidationEmail.text = ValidationStrings.kInvalidEmail
                self.cstHeightEmailValidationView.constant = 16
                self.textFieldEmail.setTextFieldBorderRed()
            } else {
                if self.textFieldPassword.text == "" {
                    self.labelValidationPassword.text = ValidationStrings.kEnterPassword
                    self.cstHeightPasswordValidationView.constant = 16
                    self.textFieldPassword.setTextFieldBorderRed()
                } else {
                    //hit api
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
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
        return true
    }
    
}
