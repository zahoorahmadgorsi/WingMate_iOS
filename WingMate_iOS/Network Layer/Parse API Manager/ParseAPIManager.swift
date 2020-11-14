//
//  ForgotPasswordAPI.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 10/31/20.
//

import Foundation
import Parse
import SVProgressHUD

struct ParseAPIManager {
    //MARK: - Login API
    static func login(email: String, password: String, onSuccess: @escaping (PFUser) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        PFUser.logInWithUsername(inBackground: email, password: password) { (user, error) in
            SVProgressHUD.dismiss()
            if let user_temp = user {
                onSuccess(user_temp)
            } else {
                onFailure(error?.localizedDescription ?? "Action failed. Please try again.")
            }
        }
    }
    
    //MARK: - Forgot Password API
    static func forgotUserPassword(email: String, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        PFUser.requestPasswordResetForEmail(inBackground: email) { (bool, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(bool)
            }
        }
    }
    
    //MARK: - Register User API
    static func registerUser(user: PFUser, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        user.signUpInBackground { (bool, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(bool)
            }
        }
    }
    
    //MARK: - Logout User API
    static func logoutUser(onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        PFUser.logOutInBackground { (error) in
            SVProgressHUD.dismiss()
            if let error = error {
                onFailure(error.localizedDescription)
            }
            else {
                onSuccess(true)
            }
        }
    }
    
    //MARK: - Resend Password API
//    static func resendPassword(email: String, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
//        SVProgressHUD.show()
//        ParseAPIManager.forgotUserPassword(email: email, onSuccess: onSuccess, onFailure: onFailure)
//    }
    
    //MARK: - Get Questionnaire
    static func getAllData(from tableName: String, whereKeyName: String, whereKeyValue: String? = "", whereKeyObject: PFObject? = nil, orderByKey: String, isWhereKeyObjectType: Bool, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        if isWhereKeyObjectType {
            query = PFQuery(className: tableName).whereKey(whereKeyName, equalTo: whereKeyObject ?? PFObject()).order(byAscending: orderByKey)
        } else {
            query = PFQuery(className: tableName).whereKey(whereKeyName, equalTo: whereKeyValue ?? "").order(byAscending: orderByKey)
        }
        query.findObjectsInBackground {(objects, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            }
            else {
                if let objs = objects {
                    onSuccess(true, objs)
                } else {
                    onFailure("No objects found")
                }
            }
        }
    }
    
    static func getAllDataWithObject(questionId: String, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        let obj = PFObject(withoutDataWithClassName: "QuestionOption", objectId: questionId)
        let query = PFQuery(className: "QuestionOption").whereKey("questionId", equalTo: obj)
        query.findObjectsInBackground {(objects, error) in
            
            if let error = error {
                onFailure(error.localizedDescription)
            }
            else {
                if let objs = objects {
                    onSuccess(true, objs)
                } else {
                    onFailure("No objects found")
                }
            }
        }
    }
    
    //MARK: - Save Questionnaire
    static func saveUserQuestionnaireOption(questionObject: PFObject, selectedOptionIds: [String], onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        let userAnswer = PFObject(className: DatabaseTable.userAnswer)
        userAnswer[DatabaseColumn.userId] = ApplicationManager.shared.session
        userAnswer[DatabaseColumn.questionId] = questionObject
        userAnswer[DatabaseColumn.selectedOptionIds] = selectedOptionIds
        userAnswer.saveEventually { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    //MARK: - Update Query
    static func updateObject(object: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        object.saveInBackground { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    //MARK: - Update user object
    static func updateUserObject(onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        
        PFUser.current()?.saveInBackground() { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    
    
}
