//
//  UserPhotoVideoModel.swift
//  WingMate_iOS
//
//  Created by Muneeb on 31/12/2020.
//

import UIKit
import Parse

struct UserPhotoVideoModel {
    var image: UIImage?
    var uploadFileUrl: String?
    var object: PFObject?
    var fileStatus: Int?
    init(image: UIImage? = UIImage(named: ""), uploadFileUrl: String? = nil, object: PFObject? = PFObject(className: "abc"), fileStatus: Int? = -1) {
        self.image = image
        self.uploadFileUrl = uploadFileUrl
        self.object = object
        self.fileStatus = fileStatus
    }
}
