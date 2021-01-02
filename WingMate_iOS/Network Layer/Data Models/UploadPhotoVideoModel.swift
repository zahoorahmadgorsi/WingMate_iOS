//
//  UploadPhotoVideoModel.swift
//  WingMate_iOS
//
//  Created by Muneeb on 28/12/2020.
//

import UIKit

struct TextTypeTerms {
    var title = ""
    var isDo = false
    init(title: String, isDo: Bool) {
        self.title = title
        self.isDo = isDo
    }
}

struct PhotoVideoTypeTerms {
//    var image = UIImage(named: "")
    var isDo = false
    var fileUrl: String?
    init(isDo: Bool, fileUrl: String? = "") {
//        self.image = image
        self.isDo = isDo
        self.fileUrl = fileUrl
    }
}
