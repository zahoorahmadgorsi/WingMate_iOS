//
//  RegisterStepOneVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 21/10/2020.
//

import UIKit

class RegisterStepOneVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelNickValidationMsg: UILabel!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var viewMale: UIView!
    @IBOutlet weak var viewFemale: UIView!
    @IBOutlet weak var viewValidationName: UIView!
    @IBOutlet weak var labelValidationName: UILabel!
    @IBOutlet weak var cstHeightNameValidationView: NSLayoutConstraint!
    var gender = 1
    var registerPresenter = RegisterPresenter()
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerPresenter.attach(vc: self)
        self.setLayout()
    }
    
    //MARK: - Helper Methods
    func setLayout() {
        self.cstHeightNameValidationView.constant = 0
    }
    
    func resetValidationFields() {
        self.cstHeightNameValidationView.constant = 0
        self.textFieldName.setTextFieldBorderClear()
    }

    //MARK: - Button Actions
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.registerPresenter.validateFieldsOnStepTwo(nickname: self.textFieldName.text ?? "")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func maleButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.gender = 1
        self.viewMale.setViewBorderRed()
        self.viewFemale.setViewBorderGray()
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.gender = 2
        self.viewMale.setViewBorderGray()
        self.viewFemale.setViewBorderRed()
    }
    
}

extension RegisterStepOneVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.appThemeYellowColor
        self.resetValidationFields()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textField.backgroundColor = UIColor.textFieldGrayBackgroundColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension RegisterStepOneVC: RegisterDelegate {
    func register(isSuccess: Bool, nicknameValidationFailedMsg: String) {
        if isSuccess {
            self.navigationController?.pushViewController(RegisterStepTwoVC(gender: self.gender, nickName: self.textFieldName.text ?? ""), animated: true)
        } else {
            self.labelValidationName.text = nicknameValidationFailedMsg
            self.cstHeightNameValidationView.constant = 16
            self.textFieldName.setTextFieldBorderRed()
        }
    }
    func register(emailValidationFailedMsg: String) {}
    func register(passwordValidationFailedMsg: String) {}
    func register(didUserRegistered: Bool, msg: String) {}
    func register(validationSuccessStepThree: Bool) {}
    func register(ageValidationFailedMsg: String) {}
}
