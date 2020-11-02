//
//  RegisterPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 02/11/2020.
//

import Foundation
import Parse

protocol RegisterDelegate {
    func register(isSuccess: Bool, nicknameValidationFailedMsg: String)
    func register(emailValidationFailedMsg: String)
    func register(passwordValidationFailedMsg: String)
    func register(didUserRegistered: Bool, msg: String)
    func register(validationSuccessStepThree: Bool)
}

class RegisterPresenter {
    
    var delegate: RegisterDelegate?
    
    func attach(vc: RegisterDelegate) {
        self.delegate = vc
    }
    
    func validateFieldsOnStepTwo(nickname: String) {
        if nickname == "" {
            self.delegate?.register(isSuccess: false, nicknameValidationFailedMsg: ValidationStrings.kEnterNickname)
        } else {
            self.delegate?.register(isSuccess: true, nicknameValidationFailedMsg: "")
        }
    }
    
    func validateFieldsOnStepThree(email: String, password: String) {
        if email == "" {
            self.delegate?.register(emailValidationFailedMsg: ValidationStrings.kEnterEmail)
        } else {
            if email.isValidEmail == false {
                self.delegate?.register(emailValidationFailedMsg: ValidationStrings.kInvalidEmail)
            } else {
                if password == "" {
                    self.delegate?.register(passwordValidationFailedMsg: ValidationStrings.kEnterPassword)
                } else {
                    if password.count <= 8 {
                        self.delegate?.register(passwordValidationFailedMsg: ValidationStrings.kPasswordMinimumLength)
                    } else {
                        self.delegate?.register(validationSuccessStepThree: true)
                    }
                }
            }
        }
    }
    
    func registerAPI(user: PFUser) {
        ParseAPIManager.registerUser(user: user) { (success) in
            self.delegate?.register(didUserRegistered: true, msg: ValidationStrings.kEmailSentToVerifyUser)
        } onFailure: { (msg) in
            self.delegate?.register(didUserRegistered: false, msg: msg)
        }
    }
}
