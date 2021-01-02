//
//  UploadPhotoVideoPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 25/12/2020.
//

import Foundation
import Parse

protocol UploadPhotoVideoDelegate {
    func uploadPhotoVideo(isSuccess: Bool, userFilesData: [PFObject], msg: String)
    func uploadPhotoVideo(isSuccess: Bool, termsData: [PFObject], msg: String)
    func uploadPhotoVideo(isFileUploaded: Bool, msg: String, pickedImage: UIImage?, obj: PFObject)
    func uploadPhotoVideo(isFileDeleted: Bool, msg: String, index: Int)
}

class UploadPhotoVideoPresenter {
    
    var delegate: UploadPhotoVideoDelegate?
    
    func attach(vc: UploadPhotoVideoDelegate) {
        self.delegate = vc
    }
    
    func getAllUploadedFilesForUser() {
        ParseAPIManager.getAllUploadedFilesForUser(currentUserId: APP_MANAGER.session?.objectId ?? "") { (success, data)  in
            if success {
                self.delegate?.uploadPhotoVideo(isSuccess: true, userFilesData: data, msg: "")
            } else {
                self.delegate?.uploadPhotoVideo(isSuccess: false, userFilesData: data, msg: "")
            }
        } onFailure: { (error) in
            self.delegate?.uploadPhotoVideo(isSuccess: false, userFilesData: [], msg: "")
        }
    }
    
    func savePhotoVideoFileToServer(pickedImage: UIImage) {
        let pngData = pickedImage.pngData()
        if let dta = pngData {
            let file = try! PFFileObject(name: "image", data: dta, contentType: "image/jpeg")
            let parseObj = PFObject(className: DBTable.userProfilePhotoVideo)
            parseObj[DBColumn.userId] = APP_MANAGER.session?.objectId ?? ""
            parseObj[DBColumn.file] = file
            parseObj[DBColumn.isPhoto] = true
            ParseAPIManager.uploadPhotoVideoFile(obj: parseObj) { (success) in
                if success {
                    self.delegate?.uploadPhotoVideo(isFileUploaded: true, msg: "Image Uploaded", pickedImage: pickedImage, obj: parseObj)
                } else {
                    self.delegate?.uploadPhotoVideo(isFileUploaded: false, msg: "Image Uploaded Failed", pickedImage: nil, obj: parseObj)
                }
            } onFailure: { (error) in
                self.delegate?.uploadPhotoVideo(isFileUploaded: false, msg: error, pickedImage: nil, obj: PFObject(className: "abc"))
            }
        }
    }
    
    func removePhotoVideoFileFromServer(obj: PFObject, index: Int) {
        ParseAPIManager.removePhotoVideoFile(obj: obj) { (success) in
            if success {
                self.delegate?.uploadPhotoVideo(isFileDeleted: true, msg: "Successfully removed", index: index)
            } else {
                self.delegate?.uploadPhotoVideo(isFileDeleted: false, msg: "Failed to remove", index: index)
            }
        } onFailure: { (error) in
            self.delegate?.uploadPhotoVideo(isFileDeleted: false, msg: error, index: index)
        }
    }
    
    func getTermsConditions() {
        ParseAPIManager.getTermsAndConditions { (success, data) in
            if success {
                self.delegate?.uploadPhotoVideo(isSuccess: true, termsData: data, msg: "Terms fetched")
            } else {
                self.delegate?.uploadPhotoVideo(isSuccess: false, termsData: [], msg: "Terms not found")
            }
        } onFailure: { (error) in
            print(error)
            self.delegate?.uploadPhotoVideo(isSuccess: false, termsData: [], msg: error)
        }
    }
    
    func getTermsConditionsText(isPhotoMode: Bool, dataTermsConditions: [PFObject]?) -> [TextTypeTerms] {
        var data = [TextTypeTerms]()
        let type = isPhotoMode ? TermsType.photoText.rawValue : TermsType.videoText.rawValue
        for i in dataTermsConditions ?? [] {
            if i.value(forKey: DBColumn.termsType) as? String ?? "" == type {
                let txt = i.value(forKey: DBColumn.text) as? String ?? ""
                let isDo = i.value(forKey: DBColumn.isDo) as? Bool ?? false
                data.append(TextTypeTerms(title: txt, isDo: isDo))
            }
        }
        return data
    }
    
    func getTermsConditionsImages(isPhotoMode: Bool, dataTermsConditions: [PFObject]?) -> [PhotoVideoTypeTerms] {
        var photosData = [PhotoVideoTypeTerms]()
        var imagesCount = 0
        for i in dataTermsConditions ?? [] {
            if isPhotoMode {
                if i.value(forKey: DBColumn.termsType) as? String ?? "" == TermsType.photo.rawValue {
                    imagesCount = imagesCount + 1
                    let isDo = i.value(forKey: DBColumn.isDo) as? Bool ?? false
                    let thumbnail = i["file"] as? PFFileObject
                    photosData.append(PhotoVideoTypeTerms(isDo: isDo, fileUrl: thumbnail?.url ?? ""))
                }
            } else {
                if i.value(forKey: DBColumn.termsType) as? String ?? "" == TermsType.video.rawValue {
                    imagesCount = imagesCount + 1
                    let isDo = i.value(forKey: DBColumn.isDo) as? Bool ?? false
                    let videoFile = i["file"] as? PFFileObject
                    photosData.append(PhotoVideoTypeTerms(isDo: isDo, fileUrl: videoFile?.url ?? ""))
                }
            }
        }
        return photosData
    }
    
}
