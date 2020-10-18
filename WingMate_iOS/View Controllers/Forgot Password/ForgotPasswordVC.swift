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
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
                //hit api
            }
        }
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
