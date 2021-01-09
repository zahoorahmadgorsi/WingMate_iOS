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
    func uploadPhotoVideo(isFileUploaded: Bool, msg: String, fileUrl: String?, obj: PFObject)
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
    
    func getUserFiles(isPhotoMode: Bool, data: [UserPhotoVideoModel], maxPhotosAllowed: Int) -> [UserPhotoVideoModel] {
        var userFilesData = [UserPhotoVideoModel]()
        if isPhotoMode {
            if data.count < maxPhotosAllowed { //total user photos are less than allowed, then add one object by default that will show current new photo picture
                userFilesData = [UserPhotoVideoModel()]
            }
            for i in data {
                let photoStatus = i.object!.value(forKey: DBColumn.isPhoto) as! Bool
                if photoStatus == isPhotoMode {
                    if data.count < maxPhotosAllowed {
                        userFilesData.insert(i, at: userFilesData.count - 1)
                    } else {
                        userFilesData.append(i)
                    }
                }
            }
        } else {
            for i in data {
                let photoStatus = i.object!.value(forKey: DBColumn.isPhoto) as! Bool
                if photoStatus == isPhotoMode {
                    userFilesData.append(i)
                    break
                }
            }
        }
        return userFilesData
    }
    
    func savePhotoVideoFileToServer(pickedImage: UIImage? = nil, videoUrl: URL? = nil) {
        var parseObj = PFObject(className: "abc")
        var file = PFFileObject(data: Data())
        if pickedImage != nil { //photo uploading
            let pngData = pickedImage!.pngData()
            if let dta = pngData {
                file = try! PFFileObject(name: "image", data: dta, contentType: "image/jpeg")
                parseObj = PFObject(className: DBTable.userProfilePhotoVideo)
                parseObj[DBColumn.userId] = APP_MANAGER.session?.objectId ?? ""
                parseObj[DBColumn.file] = file
                parseObj[DBColumn.isPhoto] = true
            }
        } else { //video uploading
            let contents: Data?
            do {
                contents = try Data(contentsOf: videoUrl!, options: NSData.ReadingOptions.alwaysMapped)
            } catch _ {
                contents = nil
            }
            if contents != nil {
                file = try! PFFileObject(name: "video", data: contents!, contentType: "video/mp4")
                parseObj = PFObject(className: DBTable.userProfilePhotoVideo)
                parseObj[DBColumn.userId] = APP_MANAGER.session?.objectId ?? ""
                parseObj[DBColumn.file] = file
                parseObj[DBColumn.isPhoto] = false
            } else {
                self.delegate?.uploadPhotoVideo(isFileUploaded: false, msg: "Upload Failed", fileUrl: nil, obj: parseObj)
            }
        }
        ParseAPIManager.uploadPhotoVideoFile(obj: parseObj) { (success) in
            if success {
                self.delegate?.uploadPhotoVideo(isFileUploaded: true, msg: "Uploaded Successfully", fileUrl: file!.url!, obj: parseObj)
            } else {
                self.delegate?.uploadPhotoVideo(isFileUploaded: false, msg: "Upload Failed", fileUrl: nil, obj: parseObj)
            }
        } onFailure: { (error) in
            self.delegate?.uploadPhotoVideo(isFileUploaded: false, msg: error, fileUrl: nil, obj: PFObject(className: "abc"))
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
