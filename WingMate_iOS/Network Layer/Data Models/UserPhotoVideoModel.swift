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
    var videoUrl: String?
    var object: PFObject?
    init(image: UIImage? = UIImage(named: ""), videoUrl: String? = nil, object: PFObject? = PFObject(className: "abc")) {
        self.image = image
        self.videoUrl = videoUrl
        self.object = object
    }
}
