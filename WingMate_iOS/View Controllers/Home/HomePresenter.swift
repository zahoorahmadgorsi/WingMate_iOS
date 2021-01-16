//
//  HomePresenter.swift
//  WingMate_iOS
//
//  Created by Danish Naeem on 1/9/21.
//

import Foundation
import UIKit

protocol HomeDelegate {
//    func uploadPhotoVideo(isSuccess: Bool, userFilesData: [PFObject], msg: String)
}

class HomePresenter {
    var delegate: HomeDelegate?
    
    public func attach(vc: HomeDelegate) {
        self.delegate = vc
    }
}
