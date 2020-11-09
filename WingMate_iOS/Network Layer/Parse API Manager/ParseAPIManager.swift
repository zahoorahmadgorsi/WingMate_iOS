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
    static func getAllData(from tableName: String, whereKeyName: String, whereKeyValue: String, orderByKey: String, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        let query = PFQuery(className: tableName).whereKey(whereKeyName, equalTo: whereKeyValue).order(byAscending: orderByKey)
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
    
    static func getAllDataWithObject(questionId: String, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        let obj = PFObject(withoutDataWithClassName: "QuestionOption", objectId: questionId)
        let query = PFQuery(className: "QuestionOption").whereKey("questionId", equalTo: obj)
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
    
    //MARK: - Save Questionnaire
    static func saveUserQuestionnaireOption(questionId: String, selectedOptionIds: [String], onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        let userAnswer = PFObject(className:"UserAnswer")
        userAnswer["userId"] = ApplicationManager.shared.session?.userId
        userAnswer["questionId"] = questionId
        userAnswer["selectedOptionIds"] = selectedOptionIds
        userAnswer.saveInBackground {
            (success: Bool, error: Error?) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                print("Option Saved")
                onSuccess(true)
            }
        }
    }
    
    
    
}

class Question {
    var title = ""
    var questionObjectId = ""
    var questionOptions = [QuestionOption()]
    init() {}
    init(title: String, questionObjectId: String, questionOptions: [QuestionOption]) {
        self.title = title
        self.questionObjectId = questionObjectId
        self.questionOptions = questionOptions
    }
}

class QuestionOption {
    var title = ""
    var questionObjectId = ""
    var optionObjectId = ""
    var countryFlag = ""
    var isUserSelected = false
    init() {}
    init(title: String, questionObjectId: String, optionObjectId: String, countryFlag: String) {
        self.title = title
        self.questionObjectId = questionObjectId
        self.optionObjectId = optionObjectId
        self.countryFlag = countryFlag
    }
}
