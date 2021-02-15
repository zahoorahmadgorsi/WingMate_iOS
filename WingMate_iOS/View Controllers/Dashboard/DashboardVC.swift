//
//  DashboardVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/11/2020.
//

import UIKit
import SVProgressHUD
import Parse

class DashboardVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.labelName.text = "Hi, \(APP_MANAGER.session?.value(forKey: DBColumn.nick) as? String ?? "")"
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: - Button Actions
    @IBAction func payNowButtonPressed(_ sender: Any) {
        if APP_MANAGER.session?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false {
            self.showToast(message: "You're already a paid user")
        } else {
            PFUser.current()?.setValue(true, forKey: DBColumn.isPaidUser)
            SVProgressHUD.show()
            ParseAPIManager.updateUserObject() { (success) in
                SVProgressHUD.dismiss()
                if success {
                    APP_MANAGER.session = PFUser.current()
                    self.showToast(message: "Congrats on becoming a paid user")
                } else {
                    self.showToast(message: "Failed to update to paid user")
                }
            } onFailure: { (error) in
                self.showToast(message: error)
            }
        }
    }
    
    @IBAction func mandatoryQuestionnaireButtonPressed(_ sender: Any) {
        let isPaidUser = APP_MANAGER.session?.value(forKey: DBColumn.isPaidUser) as? Bool
        if isPaidUser ?? false {
            self.navigationController?.pushViewController(QuestionnairesVC(isMandatoryQuestionnaires: true), animated: true)
        } else {
            self.showToast(message: "You are not a paid user")
        }
    }
    
    @IBAction func optionalQuestionnaireButtonPressed(_ sender: Any) {
        let isPaidUser = APP_MANAGER.session?.value(forKey: DBColumn.isPaidUser) as? Bool
        if isPaidUser ?? false {
            self.navigationController?.pushViewController(QuestionnairesVC(isMandatoryQuestionnaires: false), animated: true)
        } else {
            self.showToast(message: "You are not a paid user")
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        ParseAPIManager.logoutUser { (success) in
            APP_MANAGER.session = nil
            self.navigationController?.popToRootViewController(animated: true)
        } onFailure: { (error) in
            self.showToast(message: error)
        }
    }
    
    @IBAction func photoVideoButtonPressed(_ sender: Any) {
        let vc = ProfileVC()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
