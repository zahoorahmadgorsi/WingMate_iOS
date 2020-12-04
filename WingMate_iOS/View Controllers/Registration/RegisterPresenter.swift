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
    func register(ageValidationFailedMsg: String)
    func register(didUserRegistered: Bool, msg: String)
    func register(validationSuccessStepThree: Bool)
    func register(isWrongEmailSent: Bool, msg: String)
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
    
    func validateFieldsOnStepThree(email: String, password: String, isValidAge: Bool) {
        if email == "" {
            self.delegate?.register(emailValidationFailedMsg: ValidationStrings.kEnterEmail)
        } else {
            if email.isValidEmail == false {
                self.delegate?.register(emailValidationFailedMsg: ValidationStrings.kInvalidEmail)
            } else {
                if password == "" {
                    self.delegate?.register(passwordValidationFailedMsg: ValidationStrings.kEnterPassword)
                } else {
                    if password.count < 6 {
                        self.delegate?.register(passwordValidationFailedMsg: ValidationStrings.kInvalidPassword)
                    } else {
                        if isValidAge == false {
                            self.delegate?.register(ageValidationFailedMsg: ValidationStrings.kInvalidAge)
                        } else {
                            self.delegate?.register(validationSuccessStepThree: true)
                        }
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
    
    func wrongEmailAPI(emailWrong: String, emailNew: String) {
        ParseAPIManager.wrongEmail(emailWrong: emailWrong, emailNew: emailNew) { (success) in
            self.delegate?.register(isWrongEmailSent: true, msg: ValidationStrings.kEmailResent)
        } onFailure: { (error) in
            self.delegate?.register(isWrongEmailSent: false, msg: ValidationStrings.kEmailResent)
        }
    }
}
