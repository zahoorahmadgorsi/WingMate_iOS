//
//  RegisterStepTwoVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 21/10/2020.
//

import UIKit

class RegisterStepTwoVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var viewMale: UIView!
    @IBOutlet weak var viewFemale: UIView!
    @IBOutlet weak var viewValidationName: UIView!
    @IBOutlet weak var labelValidationName: UILabel!
    @IBOutlet weak var cstHeightNameValidationView: NSLayoutConstraint!
    var gender = 1
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if self.textFieldName.text == "" {
            self.cstHeightNameValidationView.constant = 16
            self.textFieldName.setTextFieldBorderRed()
        } else {
            //hit api
            self.navigationController?.pushViewController(RegisterStepThreeVC(), animated: true)
        }
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

extension RegisterStepTwoVC: UITextFieldDelegate {
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
