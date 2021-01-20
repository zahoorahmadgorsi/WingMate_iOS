//
//  EditNamePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 20/01/2021.
//

protocol EditNameDelegate {
    func editName(isSuccess: Bool, msg: String)
}

import Foundation
import Parse
import SVProgressHUD

class EditNamePresenter {
    
    var delegate: EditNameDelegate?
    
    func attach(vc: EditNameDelegate) {
        self.delegate = vc
    }
    
    func updateNickOrAboutme(text: String, isAboutme: Bool) {
        if isAboutme {
            PFUser.current()?.setValue(text, forKey: DBColumn.aboutMe)
        } else {
            PFUser.current()?.setValue(text, forKey: DBColumn.nick)
        }
        SVProgressHUD.show()
        ParseAPIManager.updateUserObject() { (success) in
            SVProgressHUD.dismiss()
            if success {
                APP_MANAGER.session = PFUser.current()
                self.delegate?.editName(isSuccess: true, msg: "Updated successfully")
            } else {
                self.delegate?.editName(isSuccess: false, msg: "Updated successfully")
            }
        } onFailure: { (error) in
            self.delegate?.editName(isSuccess: false, msg: error)
        }
    }
}
