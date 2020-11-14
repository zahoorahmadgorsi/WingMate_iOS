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
    
    //MARK: - User Auth Flow APIs
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
    
    static func updateUserObject(onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        PFUser.current()?.saveInBackground() { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    static func resendEmail(email: String, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        PFCloud.callFunction(inBackground: DatabaseColumn.cloudFunctionResendVerificationEmail, withParameters: [DatabaseColumn.email: email]) { (data, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    //MARK: - Questionnaire Flow APIs
    static func getQuestions(questionType: String? = "", onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DatabaseTable.question).whereKey(DatabaseColumn.questionType, equalTo: questionType ?? "").order(byAscending: DatabaseColumn.displayOrder)
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
    
    static func getQuestionOptions(questionObject: PFObject? = nil, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DatabaseTable.questionOption).whereKey(DatabaseColumn.questionId, equalTo: questionObject ?? PFObject()).order(byAscending: DatabaseColumn.optionId)
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
    
    static func getUserSavedOptions(questionObject: PFObject, whereKeyValue: String? = "", onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DatabaseTable.userAnswer).whereKey(DatabaseColumn.questionId, equalTo: questionObject).whereKey(DatabaseColumn.userId, equalTo: APP_MANAGER.session!)
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
    
    static func saveUserQuestionOptions(questionObject: PFObject, selectedOptionIds: [String], onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
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
    
    static func updateUserQuestionOptions(object: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        object.saveInBackground { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    
    
    
    
    
    
}
