//
//  RegisterStepThreeVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 22/10/2020.
//

import UIKit
import Parse

class RegisterStepThreeVC: BaseViewController {

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
    var genderType = -1
    var nickName = ""
    var registerPresenter = RegisterPresenter()
    
    convenience init(gender: Int, nickName: String) {
        self.init()
        self.genderType = gender
        self.nickName = nickName
    }
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerPresenter.attach(vc: self)
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
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func showPasswordButtonPressed(_ sender: Any) {
        self.shouldShowPassword = !self.shouldShowPassword
        self.textFieldPassword.isSecureTextEntry = self.shouldShowPassword
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.registerPresenter.validateFieldsOnStepThree(email: self.textFieldEmail.text ?? "", password: self.textFieldPassword.text ?? "")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension RegisterStepThreeVC: UITextFieldDelegate {
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

extension RegisterStepThreeVC: RegisterDelegate {
    func register(isSuccess: Bool, nicknameValidationFailedMsg: String) {}
    
    func register(emailValidationFailedMsg: String) {
        self.labelValidationEmail.text = emailValidationFailedMsg
        self.cstHeightEmailValidationView.constant = 16
        self.textFieldEmail.setTextFieldBorderRed()
    }
    
    func register(passwordValidationFailedMsg: String) {
        self.labelValidationPassword.text = passwordValidationFailedMsg
        self.cstHeightPasswordValidationView.constant = 16
        self.textFieldPassword.setTextFieldBorderRed()
    }
    
    func register(validationSuccessStepThree: Bool) {
        if validationSuccessStepThree {
            let user = PFUser()
            user.email = self.textFieldEmail.text ?? ""
            user.password = self.textFieldPassword.text ?? ""
            user.username = self.textFieldEmail.text ?? ""
            user.setValue(self.nickName, forKey: "nick")
            user.setValue(false, forKey: "isPaidUser")
//            user.setValue(true, forKey: "questionnaireFilled")
            user.setValue(false, forKey: "isMandatoryQuestionnairesFilled")
            user.setValue(false, forKey: "isOptionalQuestionnairesFilled")
            user.setValue(self.genderType == 1 ? "male" : "female", forKey: "gender")
            self.registerPresenter.registerAPI(user: PFUser())
        }
    }
    
    func register(didUserRegistered: Bool, msg: String) {
        if didUserRegistered {
            Utilities.shared.showSuccessBanner(msg: msg)
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            Utilities.shared.showErrorBanner(msg: msg)
        }
    }
}
