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

    func getUsers(shouldShowLoader: Bool? = true) {
        if shouldShowLoader ?? false {
            SVProgressHUD.show()
        }
        
        ParseAPIManager.getDashboardUsers { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                var dataUsers = [PFUser]()
                let myUser = PFUser.current()
                for i in data {
                    let isUserUnsubscribed = i["isUserUnsubscribed"] as? Bool ?? false
                    let usersGender = i["gender"] as? String ?? ""
                    
                    if isUserUnsubscribed == false {
                        if usersGender != myUser?.value(forKey: "gender") as! String {
                            dataUsers.append(i as! PFUser)
                        }
                    }
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
