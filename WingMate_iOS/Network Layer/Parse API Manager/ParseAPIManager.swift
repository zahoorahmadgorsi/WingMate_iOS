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
        query.includeKeys([DBColumn.optionsObjArray])
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
    
    static func saveUserQuestionOptions(questionObject: PFObject, selectedOptionIds: [String], savedOptionsObjects: [PFObject], onSuccess: @escaping (Bool, PFObject?) -> Void, onFailure:@escaping (String) -> Void) {
        let userAnswer = PFObject(className: DBTable.userAnswer)
        userAnswer[DBColumn.userId] = ApplicationManager.shared.session
        userAnswer[DBColumn.questionId] = questionObject
        userAnswer[DBColumn.selectedOptionIds] = selectedOptionIds
        userAnswer[DBColumn.optionsObjArray] = savedOptionsObjects
        
        /*let relation = userAnswer.relation(forKey: DBColumn.questionOptionsRelation)
        for i in savedOptionsObjects {
            relation.add(i)
        }*/
        
        userAnswer.saveEventually { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true, userAnswer)
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
    static func getAllUploadedFilesForUser(currentUserId: String, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DBTable.userProfilePhotoVideo).whereKey(DBColumn.userId, equalTo: currentUserId).order(byAscending: DBColumn.createdAt)
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
    
    static func uploadPhotoVideoFile(obj: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        SVProgressHUD.show()
        obj.saveInBackground { (success, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
    static func removeObject(obj: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
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
    
    //MARK: - Profile
    static func getUserSavedQuestions(user: PFUser, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DBTable.userAnswer).whereKey(DBColumn.userId, equalTo: user)
        query.includeKeys([DBColumn.questionId, DBColumn.optionsObjArray])
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
    
    static func markUserFanType(user: PFUser, fanType: String, onSuccess: @escaping (Bool, PFObject?) -> Void, onFailure:@escaping (String) -> Void) {
        let fan = PFObject(className: DBTable.fans)
        fan[DBColumn.fromUser] = ApplicationManager.shared.session
        fan[DBColumn.toUser] = user
        fan[DBColumn.fanType] = fanType
        
        fan.saveEventually { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true, fan)
            }
        }
    }
    
    static func getFansMarkedByMe(user: PFUser, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DBTable.fans).whereKey(DBColumn.fromUser, equalTo: APP_MANAGER.session!).whereKey(DBColumn.toUser, equalTo: user)
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
    
    //MARK: - Edit Profile
    static func getAllQuestions(onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DBTable.question).order(byAscending: DBColumn.profileDisplayOrder)
        query.includeKeys([DBColumn.optionsObjArray])
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
    
    //MARK: - Search
    static func searchUsers(data: UserProfileQuestion, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DBTable.userAnswer)
        query.includeKeys([DBColumn.optionsObjArray, DBColumn.userId])
        
        query.whereKey(DBColumn.optionsObjArray, containedIn: data.getUserSelectedOptionsArray())

        query.findObjectsInBackground {(objects, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            }
            else {
                if let objs = objects {
                    print("Total: \(objs.count)")
                    onSuccess(true, objs)
                } else {
                    onFailure("No objects found")
                }
            }
        }
    }
    
    //MARK: - Dashboard APIs
    static func getDashboardUsers(onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
//        var query = PFQuery()
        var query = PFUser.query()!
        query.whereKey(DBColumn.objectId, notEqualTo: APP_MANAGER.session?.objectId ?? "")
        query.includeKeys([DBColumn.optionalQuestionAnswersList, DBColumn.mandatoryQuestionAnswersList, "\(DBColumn.optionalQuestionAnswersList).\(DBColumn.questionId)", "\(DBColumn.optionalQuestionAnswersList).\(DBColumn.optionsObjArray)", "\(DBColumn.mandatoryQuestionAnswersList).\(DBColumn.questionId)", "\(DBColumn.mandatoryQuestionAnswersList).\(DBColumn.optionsObjArray)"])
        
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

    //MARK: - Backend Work
    static func updateQuestionOptions(questionObject: PFObject, onSuccess: @escaping (Bool) -> Void, onFailure:@escaping (String) -> Void) {
        questionObject.saveInBackground { (success, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true)
            }
        }
    }
    
}
