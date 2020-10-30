//
//  LoginAPI.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 10/13/20.
//

import Foundation
import Parse

struct LoginAPI {
    
    static func login(email: String, password: String, onSuccess: @escaping (PFUser) -> Void, onFailure:@escaping (String) -> Void) {
        PFUser.logInWithUsername(inBackground: email, password: password) { (user, error) in
            if let user_temp = user {
                onSuccess(user_temp)
            } else {
                onFailure(error?.localizedDescription ?? "Action failed. Please try again.")
            }
        }
    }
}
