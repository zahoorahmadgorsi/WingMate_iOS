//
//  SignUp.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 10/13/20.
//

import Foundation
import Parse

struct RegisterAPI {
    
    static func createUser(email: String, password: String, nick: String, gender: String, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        let user = PFUser()
        user.username = email
        user.password = password
        user.email = email
        user["gender"] = gender
        user["nick"] = nick
        
        user.signUpInBackground { (bool, error) in
            if let error = error {
                onFailure(error.localizedDescription ?? "Action failed. Please try again.")
            } else {
                onSuccess(bool)
            }
        }
    }
    
}
