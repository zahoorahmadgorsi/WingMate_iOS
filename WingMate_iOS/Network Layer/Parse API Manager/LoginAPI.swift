//
//  LoginAPI.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 10/13/20.
//

import Foundation
import Parse

struct LoginAPI {
    
    func login(email: String, password: String) {
//        PFUser.logInWithUsername(inBackground: email, password: password)
        
        PFUser.logInWithUsername(inBackground: email, password: password) { (user, error) in
            if error == nil {
                
            }
            else {
                print(user)
            }
        }
        
//        logInWithUsername(inBackground: email, password: password) { (user: PFUser?, error: NSError?) in
//
//        }
        
//        PFUser.logInWithUsernameInBackground("<userName>", password:"<password>") {
//          (user: PFUser?, error: NSError?) -> Void in
//          if user != nil {
//            // Do stuff after successful login.
//          } else {
//            // The login failed. Check error to see why.
//          }
//        }
    }
    
}
