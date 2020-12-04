//
//  EmailVerificationPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 03/11/2020.
//

import Foundation
import Parse
import SVProgressHUD

protocol EmailVerificationDelegate {
    func emailVerification(didResendEmailSuccessfully: Bool, msg: String)
}

class EmailVerificationPresenter {
    
    var delegate: EmailVerificationDelegate?
    
    func attach(vc: EmailVerificationDelegate) {
        self.delegate = vc
    }
    
    func resendEmailAPI(email: String) {
        SVProgressHUD.show()
        ParseAPIManager.resendEmail(email: email) { (success) in
            SVProgressHUD.dismiss()
            self.delegate?.emailVerification(didResendEmailSuccessfully: true, msg: ValidationStrings.kEmailResent)
        } onFailure: { (error) in
            self.delegate?.emailVerification(didResendEmailSuccessfully: false, msg: error)
        }
    }
}
