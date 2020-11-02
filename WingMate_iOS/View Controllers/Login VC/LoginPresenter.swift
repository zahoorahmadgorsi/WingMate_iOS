//
//  LoginPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 02/11/2020.
//

protocol LoginDelegate {
    func login(emailValidationFailedMsg: String)
    func login(passwordValidationFailedMsg: String)
    func login(didUserLoggedIn: Bool, msg: String)
}

import Foundation

class LoginPresenter {
    
    var delegate: LoginDelegate?
    
    func attach(vc: LoginDelegate) {
        self.delegate = vc
    }
    
    func checkForValidations(email: String, password: String) {
        if email == "" {
            self.delegate?.login(emailValidationFailedMsg: ValidationStrings.kEnterEmail)
        } else {
            if email.isValidEmail == false {
                self.delegate?.login(emailValidationFailedMsg: ValidationStrings.kInvalidEmail)
            } else {
                if password == "" {
                    self.delegate?.login(passwordValidationFailedMsg: ValidationStrings.kEnterPassword)
                } else {
                    if password.count <= 8 {
                        self.delegate?.login(passwordValidationFailedMsg: ValidationStrings.kPasswordMinimumLength)
                    } else {
                        self.loginAPI(email: email, password: password)
                    }
                }
            }
        }
    }
    
    func loginAPI(email: String, password: String) {
        ParseAPIManager.login(email: "danishnaeem57@gmail.com", password: "123456") { (user) in
            let email = user.value(forKey: "email") as? String ?? ""
            let isEmailVerified = user.value(forKey: "emailVerified") as? Bool ?? false
            let gender = user.value(forKey: "gender") as? String ?? ""
            let nick = user.value(forKey: "nick") as? String ?? ""
            let isPaidUser = user.value(forKey: "isPaidUser") as? Bool ?? false
            let isMandatoryQuestionnairesFilled = user.value(forKey: "isMandatoryQuestionnairesFilled") as? Bool ?? false
            let isOptionalQuestionnairesFilled = user.value(forKey: "isOptionalQuestionnairesFilled") as? Bool ?? false
            
            APP_MANAGER.session = User(email: email, isEmailVerified: isEmailVerified, gender: gender, nickName: nick, isPaidUser: isPaidUser, isMandatoryQuestionnairesFilled: isMandatoryQuestionnairesFilled, isOptionalQuestionnairesFilled: isOptionalQuestionnairesFilled)
            APP_MANAGER.isLoggedIn = true
            
            self.delegate?.login(didUserLoggedIn: true, msg: "User logged in successfully")
        
        } onFailure: { (msg) in
            self.delegate?.login(didUserLoggedIn: false, msg: msg)
        }
    }
}
