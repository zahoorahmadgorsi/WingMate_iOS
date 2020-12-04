//
//  RegisterStepTwoVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 22/10/2020.
//

import UIKit
import Parse

class RegisterStepTwoVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var viewValidationEmail: UIView!
    @IBOutlet weak var labelGreetings: UILabel!
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
    var genderType = -1
    var nickName = ""
    var registerPresenter = RegisterPresenter()
    var isValidAge = false
    
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
        self.labelGreetings.text = "Hi, \(self.nickName)"
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
    @IBAction func ageCheckButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.isValidAge = !self.isValidAge
        self.imageViewCheckBox.image = self.isValidAge ? UIImage(named: "checked") : UIImage(named: "unchecked")
    }
    
    @IBAction func showPasswordButtonPressed(_ sender: Any) {
        self.shouldShowPassword = !self.shouldShowPassword
        self.textFieldPassword.isSecureTextEntry = self.shouldShowPassword ? false : true
        let img = self.shouldShowPassword ? UIImage(named: "showpassword") : UIImage(named: "hidepassword")
        self.buttonShowPassword.setImage(img, for: .normal)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.registerPresenter.validateFieldsOnStepThree(email: self.textFieldEmail.text ?? "", password: self.textFieldPassword.text ?? "", isValidAge: self.isValidAge)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        if isWrongEmailPressed {
            isWrongEmailPressed = false
            oldEmail = ""
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
}

extension RegisterStepTwoVC: UITextFieldDelegate {
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

extension RegisterStepTwoVC: RegisterDelegate {
    func register(isSuccess: Bool, nicknameValidationFailedMsg: String) {}
    func register(didUserRegistered: Bool, msg: String) {}
    
    func register(emailValidationFailedMsg: String) {
        self.labelValidationEmail.text = emailValidationFailedMsg
        self.cstHeightEmailValidationView.constant = 16
        self.textFieldEmail.setTextFieldBorderRed()
    }
    
    func register(passwordValidationFailedMsg: String) {
        self.labelValidationPassword.text = passwordValidationFailedMsg
        self.cstHeightPasswordValidationView.constant = 16
        self.cstTopPasswordValidationView.constant = 12
        self.textFieldPassword.setTextFieldBorderRed()
    }
    
    func register(ageValidationFailedMsg: String) {
        self.showToast(message: ageValidationFailedMsg)
    }
    
    func register(validationSuccessStepThree: Bool) {
        if validationSuccessStepThree {
            //make user object and pass to terms and conditions
            let user = PFUser()
            user.email = self.textFieldEmail.text ?? ""
            user.password = self.textFieldPassword.text ?? ""
            user.username = self.textFieldEmail.text ?? ""
            user.setValue(self.nickName, forKey: "nick")
            user.setValue(false, forKey: "isPaidUser")
            user.setValue(false, forKey: "isMandatoryQuestionnairesFilled")
            user.setValue(false, forKey: "isOptionalQuestionnairesFilled")
            user.setValue(self.genderType == 1 ? "male" : "female", forKey: "gender")
            self.navigationController?.pushViewController(TermsAndConditionsVC(user: user), animated: true)
        }
    }
    
    func register(isWrongEmailSent: Bool, msg: String) {
        
    }
    
    
}
