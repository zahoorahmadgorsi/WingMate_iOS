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
    
}
