//
//  DashboardPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 17/02/2021.
//


import Foundation
import Parse
import SVProgressHUD

protocol DashboardDelegate {
    func dashboard(isSuccess: Bool, msg: String, users: [PFUser])
}

class DashboardPresenter {
    
    var delegate: DashboardDelegate?
    
    func attach(vc: DashboardDelegate) {
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
                self.delegate?.dashboard(isSuccess: true, msg: "", users: dataUsers)
            } else {
                self.delegate?.dashboard(isSuccess: false, msg: "No questions found", users: [])
            }
        } onFailure: { (error) in
            print(error)
            SVProgressHUD.dismiss()
            self.delegate?.dashboard(isSuccess: false, msg: error, users: [])
        }
    }
    
}
