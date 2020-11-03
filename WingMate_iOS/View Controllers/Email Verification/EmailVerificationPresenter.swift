//
//  EmailVerificationPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 03/11/2020.
//

import Foundation
import Parse

protocol EmailVerificationDelegate {
    func emailVerification(didResendEmailSuccessfully: Bool)
}

class EmailVerificationPresenter {
    
    var delegate: EmailVerificationDelegate?
    
    func attach(vc: EmailVerificationDelegate) {
        self.delegate = vc
    }
    
    func resendEmailAPI(user: PFUser) {
        let email = user.value(forKey: "email") as? String ?? ""
        print(email)
        //call parse api manager method of resend email here
        //on success, call -> self.delegate?.emailVerification(didResendEmailSuccessfully: true)
        
    }
    
}
