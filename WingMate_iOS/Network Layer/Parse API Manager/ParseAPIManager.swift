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
        PFCloud.callFunction(inBackground: DBCloudFunction.cloudFunctionResendVerificationEmail, withParameters: [DBColumn.email: email]) { (data, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    static func wrongEmail(emailWrong: String, emailNew: String, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        let params = [
            DBColumn.emailWrong: emailWrong,
            DBColumn.emailNew: emailNew
        ]
        PFCloud.callFunction(inBackground: DBCloudFunction.cloudFunctionUpdateWrongEmail, withParameters: params) { (data, error) in
            SVProgressHUD.dismiss()
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
        query = PFQuery(className: DBTable.question).whereKey(DBColumn.questionType, equalTo: questionType ?? "").order(byAscending: DBColumn.displayOrder)
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
        query = PFQuery(className: DBTable.questionOption).whereKey(DBColumn.questionId, equalTo: questionObject ?? PFObject()).order(byAscending: DBColumn.optionId)
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
        query = PFQuery(className: DBTable.userAnswer).whereKey(DBColumn.questionId, equalTo: questionObject).whereKey(DBColumn.userId, equalTo: APP_MANAGER.session!)
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
        let userAnswer = PFObject(className: DBTable.userAnswer)
        userAnswer[DBColumn.userId] = ApplicationManager.shared.session
        userAnswer[DBColumn.questionId] = questionObject
        userAnswer[DBColumn.selectedOptionIds] = selectedOptionIds
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
    
    //MARK: - Terms Conditions APIs
    static func getTermsAndConditions(onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        var query = PFQuery()
        query = PFQuery(className: DBTable.termsConditions)
        query.findObjectsInBackground {(objects, error) in
            SVProgressHUD.dismiss()
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
    
    //MARK: - Upload Photo Video APIs
    static func uploadPhotoVideoFile(obj: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        obj.saveEventually { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    static func removePhotoVideoFile(obj: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        obj.deleteInBackground { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
}
