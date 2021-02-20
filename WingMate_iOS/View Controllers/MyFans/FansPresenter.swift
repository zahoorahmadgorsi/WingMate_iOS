//
//  FansPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/02/2021.
//

import Foundation
import Parse
import SVProgressHUD

protocol FansDelegate {
    func fans(isSuccess: Bool, msg: String, users: [PFUser])
}

class FansPresenter {
    
    var delegate: FansDelegate?
    
    func attach(vc: FansDelegate) {
        self.delegate = vc
    }

    func getUsers() {
        SVProgressHUD.show()
        ParseAPIManager.getDashboardUsers { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                var dataUsers = [PFUser]()
                for i in data {
                    dataUsers.append(i as! PFUser)
                }
                self.delegate?.fans(isSuccess: true, msg: "", users: dataUsers)
            } else {
                self.delegate?.fans(isSuccess: false, msg: "No questions found", users: [])
            }
        } onFailure: { (error) in
            print(error)
            SVProgressHUD.dismiss()
            self.delegate?.fans(isSuccess: false, msg: error, users: [])
        }
    }
    
}
