//
//  ProfilePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/01/2021.
//

import Foundation
import Parse
import SVProgressHUD

protocol ProfileDelegate: class {
    func profile(isSuccess: Bool, userFilesData: [PFObject], msg: String)
    func profile(isSuccess: Bool, userSavedQuestions: [PFObject], msg: String)
    func profile(isSuccess: Bool, msg: String, markedUnmarkedUserFanType: FanType, isDeleted: Bool, object: PFObject?)
    func profile(isSuccess: Bool, msg: String, fansMarkedByMe: [PFObject])
}

class ProfilePresenter {
    
    weak var delegate: ProfileDelegate?
    
    func attach(vc: ProfileDelegate) {
        self.delegate = vc
    }
    
    func getAllUploadedFilesForUser(currentUserId: String, shouldShowLoader: Bool, isFromViewDidLoad: Bool) {
        if shouldShowLoader {
            SVProgressHUD.show()
        }
        ParseAPIManager.getAllUploadedFilesForUser(currentUserId: currentUserId) { (success, data)  in
            if shouldShowLoader && isFromViewDidLoad == false {
                SVProgressHUD.dismiss()
            }
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
    
    func getUserSavedQuestions(user: PFUser, shouldShowLoader: Bool) {
        if shouldShowLoader {
            SVProgressHUD.show()
        }
        ParseAPIManager.getUserSavedQuestions(user: user) { (success, data) in
            if shouldShowLoader {
                SVProgressHUD.dismiss()
            }
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
    
    func getUserPhotosVideos(data: [UserPhotoVideoModel], isPhotos: Bool) -> [UserPhotoVideoModel] {
        var userFilesData = [UserPhotoVideoModel]()
        for i in data {
            let photoStatus = i.object!.value(forKey: DBColumn.isPhoto) as! Bool
            if photoStatus == isPhotos {
                userFilesData.append(i)
            }
        }
        return userFilesData
    }
    
    func markUserAsFan(user: PFUser, fanType: FanType) {
        SVProgressHUD.show()
        ParseAPIManager.markUserFanType(user: user, fanType: fanType.rawValue) { (success, obj) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.profile(isSuccess: true, msg: "Updated successfully", markedUnmarkedUserFanType: fanType, isDeleted: false, object: obj)
            } else {
                self.delegate?.profile(isSuccess: false, msg: "Unable to unmark", markedUnmarkedUserFanType: fanType, isDeleted: false, object: nil)
            }
        } onFailure: { (error) in
            SVProgressHUD.dismiss()
            self.delegate?.profile(isSuccess: false, msg: error, markedUnmarkedUserFanType: fanType, isDeleted: false, object: nil)
        }
    }
    
    func unmarkUserAsFan(object: PFObject, fanType: FanType) {
        SVProgressHUD.show()
        ParseAPIManager.removeObject(obj: object) { (success) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.profile(isSuccess: true, msg: "Updated successfully", markedUnmarkedUserFanType: fanType, isDeleted: true, object: nil)
            } else {
                self.delegate?.profile(isSuccess: false, msg: "Unable to unmark", markedUnmarkedUserFanType: fanType, isDeleted: true, object: nil)
            }
        } onFailure: { (error) in
            SVProgressHUD.dismiss()
            self.delegate?.profile(isSuccess: false, msg: error, markedUnmarkedUserFanType: fanType, isDeleted: false, object: nil)
        }
    }
    
    func getFansMarkedByMe(user: PFUser) {
        SVProgressHUD.show()
        ParseAPIManager.getFansMarkedByMe(user: user) { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.profile(isSuccess: true, msg: "", fansMarkedByMe: data)
            } else {
                self.delegate?.profile(isSuccess: false, msg: "No data found", fansMarkedByMe: [])
            }
        } onFailure: { (error) in
            SVProgressHUD.dismiss()
            self.delegate?.profile(isSuccess: false, msg: error, fansMarkedByMe: [])
        }
    }
    
    func pushNotification(title: String, msg: String, userId: String) {
        ParseAPIManager.sendPushNotification(title: title, message: msg, userObjectId: userId) { success, message in
            print("Push notification sent: \(success). Message: \(message)")
        } onFailure: { error in
            print("Push notification error: \(msg)")
        }
    }
    
}
