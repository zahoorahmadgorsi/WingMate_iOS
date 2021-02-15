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
    
    //MARK: - Profile
    static func getUserSavedQuestions(onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        var query = PFQuery()
        query = PFQuery(className: DBTable.userAnswer).whereKey(DBColumn.userId, equalTo: APP_MANAGER.session!)
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
        /*
        var query = PFQuery()
        query = PFQuery(className: DBTable.userAnswer)
        let obj = PFObject(withoutDataWithClassName:  DBTable.questionOption, objectId: "tKmc2CXpHs")
//        query.includeKeys([DBColumn.questionId, DBColumn.optionsObjArray])
        query.whereKey (DBColumn.optionsObjArray, equalTo: obj)
        
        var query2 = PFQuery()
        query2 = PFQuery(className: DBTable.userAnswer)
        let obj2 = PFObject(withoutDataWithClassName:  DBTable.questionOption, objectId: "dOpfs3lpLn")
//        query2.includeKeys([DBColumn.questionId, DBColumn.optionsObjArray])
        query2.whereKey (DBColumn.optionsObjArray, equalTo: obj2)
        
        
      let qry = PFQuery.orQuery(withSubqueries: [query, query2])
        
        qry.findObjectsInBackground {(objects, error) in
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
        */
        
        
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
