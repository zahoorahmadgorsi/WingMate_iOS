//
//  ProfilePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/01/2021.
//

import Foundation
import Parse
import SVProgressHUD

protocol ProfileDelegate {
    func profile(isSuccess: Bool, userFilesData: [PFObject], msg: String)
    func profile(isSuccess: Bool, userSavedQuestions: [PFObject], msg: String)
}

class ProfilePresenter {
    
    var delegate: ProfileDelegate?
    
    func attach(vc: ProfileDelegate) {
        self.delegate = vc
    }
    
    func getAllUploadedFilesForUser() {
        SVProgressHUD.show()
        ParseAPIManager.getAllUploadedFilesForUser(currentUserId: APP_MANAGER.session?.objectId ?? "") { (success, data)  in
            if success {
                self.delegate?.profile(isSuccess: true, userFilesData: data, msg: "")
            } else {
                self.delegate?.profile(isSuccess: false, userFilesData: data, msg: "")
            }
        } onFailure: { (error) in
            SVProgressHUD.dismiss()
            self.delegate?.profile(isSuccess: false, userFilesData: [], msg: "")
        }
    }
    
    func getUserSavedQuestions() {
        ParseAPIManager.getUserSavedQuestions { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.profile(isSuccess: true, userSavedQuestions: data, msg: "")
            } else {
                self.delegate?.profile(isSuccess: false, userSavedQuestions: data, msg: "")
            }
        } onFailure: { (error) in
            SVProgressHUD.dismiss()
            self.delegate?.profile(isSuccess: false, userSavedQuestions: [], msg: "")
        }
    }
    
    func getUserPhotos(data: [UserPhotoVideoModel]) -> [UserPhotoVideoModel] {
        var userFilesData = [UserPhotoVideoModel]()
        for i in data {
            let photoStatus = i.object!.value(forKey: DBColumn.isPhoto) as! Bool
            if photoStatus == true {
                userFilesData.append(i)
            }
        }
        return userFilesData
    }
    
    func getUserQuestionAndAnswer(data: [PFObject]) -> UserProfilePDO {
        let userProfilePDO = UserProfilePDO()
        for i in data {
            let questionObj = i.value(forKey: DBColumn.questionId) as! PFObject
            let questionShortTitle = questionObj.value(forKey: DBColumn.shortTitle) as? String ?? ""
            let optionsObj = i.value(forKey: DBColumn.optionsObjArray) as? Array<PFObject>
            let optionSelectedTitle = optionsObj?[0].value(forKey: DBColumn.title) as? String ?? ""
            let pdo = UserProfileQuestionAnswerPDO(shortQuestionTitle: questionShortTitle, optionSelected: optionSelectedTitle)
            if questionShortTitle == QuestionShortTitle.age {
                userProfilePDO.age = pdo
            } else if questionShortTitle == QuestionShortTitle.height {
                userProfilePDO.height = pdo
            } else if questionShortTitle == QuestionShortTitle.nationality {
                userProfilePDO.nationality = pdo
            } else if questionShortTitle == QuestionShortTitle.lookingFor {
                userProfilePDO.lookingFor = pdo
            }
        }
        userProfilePDO.aboutMe = APP_MANAGER.session?.value(forKey: DBColumn.aboutMe) as? String ?? ""
        return userProfilePDO
    }
    
}

class UserProfilePDO {
    var age = UserProfileQuestionAnswerPDO()
    var height = UserProfileQuestionAnswerPDO()
    var nationality = UserProfileQuestionAnswerPDO()
    var lookingFor = UserProfileQuestionAnswerPDO()
    var aboutMe = ""
}

class UserProfileQuestionAnswerPDO {
    var shortQuestionTitle = ""
    var optionSelected = ""
    
    init(){}
    
    init(shortQuestionTitle: String, optionSelected: String) {
        self.shortQuestionTitle = shortQuestionTitle
        self.optionSelected = optionSelected
    }
}

/*
 for (i, item) in options.enumerated() {
     if i == options.count - 1 {
         ageIs += item.value(forKey: DBColumn.title) as? String ?? ""
     } else {
         ageIs += item.value(forKey: DBColumn.title) as? String ?? ""
     }
 }
 */
