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
                NotificationCenter.default.post(name: Notification.Name("resetBottomFloatingViewText"), object: nil, userInfo: nil)
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
    
    //MARK: - Get Server Date
    static func getServerDate(onSuccess: @escaping (Bool, String) -> Void, onFailure:@escaping (String) -> Void) {
        PFCloud.callFunction(inBackground: DBCloudFunction.cloudFunctionServerDate, withParameters: nil) { (data, error) in
            if let error = error {
                onFailure(error.localizedDescription)
            } else {
                onSuccess(true, data as? String ?? "")
            }
        }
    }
    
    //MARK: - Push Notification
    static func sendPushNotification(title: String, message: String, userObjectId: String? = "", onSuccess: @escaping (Bool, String) -> Void, onFailure:@escaping (String) -> Void) {
        let params: [String: Any]?
        var url = ""
        if userObjectId == "" {
            params = ["alertTitle": title, "alertText": message]
            url = DBCloudFunction.pushToAdmin
        } else {
            params = ["alertTitle": "Fans", "alertText": message, "userId": userObjectId!]
            url = DBCloudFunction.pushToUser
        }
        PFCloud.callFunction(inBackground: url, withParameters: params!) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Push notification sent successfully")
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
        query.limit = 1000
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
        if currentUserId == PFUser.current()?.objectId ?? "" {
            query = PFQuery(className: DBTable.userProfilePhotoVideo).whereKey(DBColumn.userId, equalTo: currentUserId).order(byAscending: DBColumn.createdAt)
            //.whereKey(DBColumn.fileStatus, notEqualTo: FileStatus.rejected.rawValue)
        } else {
            query = PFQuery(className: DBTable.userProfilePhotoVideo).whereKey(DBColumn.userId, equalTo: currentUserId).order(byAscending: DBColumn.createdAt).whereKey(DBColumn.fileStatus, equalTo: FileStatus.accepted.rawValue)
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
        let isTouserIsUnsub = user["isUserUnsubscribed"] as? Bool ?? false
        let fan = PFObject(className: DBTable.fans)
        fan[DBColumn.fromUser] = ApplicationManager.shared.session
        fan[DBColumn.toUser] = user
        fan[DBColumn.fanType] = fanType
        fan["istoUserIsUnsub"] = isTouserIsUnsub
        
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
        
        query.includeKeys([DBColumn.userId, "\(DBColumn.userId).\(DBColumn.optionalQuestionAnswersList)", "\(DBColumn.userId).\(DBColumn.mandatoryQuestionAnswersList)", "\(DBColumn.userId).\(DBColumn.optionalQuestionAnswersList).\(DBColumn.questionId)", "\(DBColumn.userId).\(DBColumn.optionalQuestionAnswersList).\(DBColumn.optionsObjArray)", "\(DBColumn.userId).\(DBColumn.mandatoryQuestionAnswersList).\(DBColumn.questionId)", "\(DBColumn.userId).\(DBColumn.mandatoryQuestionAnswersList).\(DBColumn.optionsObjArray)"])
        
        
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
    
    static func getUsersBasedOnDistance(distanceInMeters: Int, onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        let query = PFUser.query()!
        let geoPoint = PFUser.current()?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint
        if geoPoint != nil {
            let myUserGroup = PFUser.current()?.value(forKey: DBColumn.groupCategory) as? String ?? ""
            if myUserGroup == "N" {
                query.whereKey(DBColumn.objectId, notEqualTo: APP_MANAGER.session?.objectId ?? "").whereKey(DBColumn.currentLocation, nearGeoPoint: geoPoint!, withinKilometers: Double(distanceInMeters/1000))
            } else {
                query.whereKey(DBColumn.objectId, notEqualTo: APP_MANAGER.session?.objectId ?? "").whereKey(DBColumn.currentLocation, nearGeoPoint: geoPoint!, withinKilometers: Double(distanceInMeters/1000)).whereKey(DBColumn.groupCategory, equalTo: myUserGroup)
            }
            
            
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
        } else {
            
        }
    }
    
    //MARK: - Dashboard APIs
    static func getDashboardUsers(onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        let query = PFUser.query()!
        let myUserGroup = PFUser.current()?.value(forKey: DBColumn.groupCategory) as? String ?? ""
        if myUserGroup == "N" {
            query.whereKey(DBColumn.objectId, notEqualTo: APP_MANAGER.session?.objectId ?? "").whereKey(DBColumn.accountStatus, equalTo: UserAccountStatus.accepted.rawValue)
        } else {
            query.whereKey(DBColumn.objectId, notEqualTo: APP_MANAGER.session?.objectId ?? "").whereKey(DBColumn.accountStatus, equalTo: UserAccountStatus.accepted.rawValue).whereKey(DBColumn.groupCategory, equalTo: myUserGroup)
        }
        
        
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
    
    //MARK: - Fans APIs
    static func getMyFans(onSuccess: @escaping (Bool, _ data: [PFObject]) -> Void, onFailure:@escaping (String) -> Void) {
        let query = PFQuery(className: DBTable.fans)
        query.whereKey(DBColumn.toUser, equalTo: APP_MANAGER.session!)
        
        let query2 = PFQuery(className: DBTable.fans)
        query2.whereKey(DBColumn.fromUser, equalTo: APP_MANAGER.session!)
        
        let queries = [query, query2]
        
        let mainQuery = PFQuery.orQuery(withSubqueries: queries)
        
        mainQuery.includeKeys([DBColumn.fromUser,
                               DBColumn.toUser,
                               "\(DBColumn.fromUser).\(DBColumn.optionalQuestionAnswersList)",
                               "\(DBColumn.fromUser).\(DBColumn.mandatoryQuestionAnswersList)",
                               "\(DBColumn.fromUser).\(DBColumn.optionalQuestionAnswersList).\(DBColumn.questionId)",
                               "\(DBColumn.fromUser).\(DBColumn.optionalQuestionAnswersList).\(DBColumn.optionsObjArray)",
                               "\(DBColumn.fromUser).\(DBColumn.mandatoryQuestionAnswersList).\(DBColumn.questionId)",
                               "\(DBColumn.fromUser).\(DBColumn.mandatoryQuestionAnswersList).\(DBColumn.optionsObjArray)",
                               "\(DBColumn.fromUser).\(DBColumn.accountStatus)",
                               "\(DBColumn.toUser).\(DBColumn.accountStatus)"
        ])
        
        
        
        mainQuery.findObjectsInBackground {(objects, error) in
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
