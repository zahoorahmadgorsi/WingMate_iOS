//
//  ForgotPasswordVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 18/10/2020.
//

import UIKit

class ForgotPasswordVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var viewValidationEmail: UIView!
    @IBOutlet weak var labelValidationEmail: UILabel!
    @IBOutlet weak var cstHeightEmailValidationView: NSLayoutConstraint!
    let forgotPasswordPresenter = ForgotPasswordPresenter()
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.forgotPasswordPresenter.attach(vc: self)
        self.setLayout()
    }
    
    //MARK: - Helper Methods
    func setLayout() {
        self.cstHeightEmailValidationView.constant = 0
    }
    
    func resetValidationViews() {
        self.textFieldEmail.backgroundColor = UIColor.textFieldGrayBackgroundColor
        self.cstHeightEmailValidationView.constant = 0
        self.labelValidationEmail.text = ""
        self.textFieldEmail.setTextFieldBorderClear()
    }

    //MARK: - Button Actions
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.forgotPasswordPresenter.checkForValidations(email: self.textFieldEmail.text ?? "")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension ForgotPasswordVC: UITextFieldDelegate {
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

extension ForgotPasswordVC: ForgotPasswordDelegate {
    func forgotPassword(emailValidationFailedMsg: String) {
        self.labelValidationEmail.text = emailValidationFailedMsg
        self.cstHeightEmailValidationView.constant = 16
        self.textFieldEmail.setTextFieldBorderRed()
    }
    
    func forgotPassword(isSuccess: Bool, msg: String) {
        if isSuccess {
            Utilities.shared.showSuccessBanner(msg: msg)
            self.navigationController?.popViewController(animated: true)
        } else {
            Utilities.shared.showErrorBanner(msg: msg)
        }
    }
    
}
