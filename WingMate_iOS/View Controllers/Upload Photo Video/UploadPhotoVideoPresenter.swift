//
//  UploadPhotoVideoPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 25/12/2020.
//

import Foundation
import Parse
import SVProgressHUD

protocol UploadPhotoVideoDelegate {
    func uploadPhotoVideoDelegate(isSuccess: Bool, termsData: [PFObject], msg: String)
}

class UploadPhotoVideoPresenter {
    
    var delegate: UploadPhotoVideoDelegate?
    
    func attach(vc: UploadPhotoVideoDelegate) {
        self.delegate = vc
    }
    
    func getTermsConditions() {
        SVProgressHUD.show()
        ParseAPIManager.getTermsAndConditions { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.uploadPhotoVideoDelegate(isSuccess: true, termsData: data, msg: "Terms fetched")
            } else {
                self.delegate?.uploadPhotoVideoDelegate(isSuccess: false, termsData: [], msg: "Terms not found")
            }
        } onFailure: { (error) in
            print(error)
            self.delegate?.uploadPhotoVideoDelegate(isSuccess: false, termsData: [], msg: error)
        }
    }
    
    func getTextTerms(isPhotoMode: Bool, dataTermsConditions: [PFObject]?) -> [TextTypeTerms] {
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
    
}
