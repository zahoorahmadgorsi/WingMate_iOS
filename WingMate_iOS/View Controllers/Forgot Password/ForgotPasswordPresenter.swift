//
//  ForgotPasswordPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 02/11/2020.
//

protocol ForgotPasswordDelegate {
    func forgotPassword(emailValidationFailedMsg: String)
    func forgotPassword(isSuccess: Bool, msg: String)
}

import Foundation

class ForgotPasswordPresenter {
    
    var delegate: ForgotPasswordDelegate?
    
    func attach(vc: ForgotPasswordDelegate) {
        self.delegate = vc
    }
    
    func checkForValidations(email: String) {
        if email == "" {
            self.delegate?.forgotPassword(emailValidationFailedMsg: ValidationStrings.kEnterEmail)
        } else {
            if email.isValidEmail == false {
                self.delegate?.forgotPassword(emailValidationFailedMsg: ValidationStrings.kInvalidEmail)
            } else {
                self.forgotPasswordAPI(email: email)
            }
        }
    }
    
    func forgotPasswordAPI(email: String) {
        ParseAPIManager.forgotUserPassword(email: email) { (success) in
            self.delegate?.forgotPassword(isSuccess: true, msg: ValidationStrings.kEmailSentToResetPassword)
        } onFailure: { (msg) in
            self.delegate?.forgotPassword(isSuccess: false, msg: msg)
        }
    }
}
