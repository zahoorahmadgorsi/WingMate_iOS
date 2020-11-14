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
                    if password.count < 6 {
                        self.delegate?.login(passwordValidationFailedMsg: ValidationStrings.kInvalidPassword)
                    } else {
                        self.loginAPI(email: email, password: password)
                    }
                }
            }
        }
    }
    
    func loginAPI(email: String, password: String) {
        ParseAPIManager.login(email: email, password: password) { (user) in
            APP_MANAGER.isLoggedIn = true
            APP_MANAGER.session = user
            self.delegate?.login(didUserLoggedIn: true, msg: "User logged in successfully")
        } onFailure: { (msg) in
            self.delegate?.login(didUserLoggedIn: false, msg: msg)
        }
    }
}
