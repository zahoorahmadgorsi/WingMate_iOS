//
//  ForgotPasswordAPI.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 10/31/20.
//

import Foundation
import Parse

struct ForgotPasswordAPI {
    static func createUser(email: String, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        PFUser.requestPasswordResetForEmail(inBackground: email) { (bool, error) in
            if let error = error {
                onFailure(error.localizedDescription ?? "Action failed. Please try again.")
            } else {
                onSuccess(bool)
            }
        }
    }
}
