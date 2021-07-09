//
//  SettingsVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 11/02/2021.
//

import UIKit
import Parse
import SVProgressHUD

class SettingsVC: BaseViewController {

    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var labelVersion: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            print("\(version).\(build)")
            self.labelVersion.text = "Version \(version).\(build)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        if PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false == true {
            self.payNowButton.isHidden = true
        } else {
            self.payNowButton.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func processUserState() {
        SVProgressHUD.show()
        self.getAccountStatus(completion: { (status) in
            
            if status == UserAccountStatus.rejected.rawValue {
                self.logoutUser()
                return
            }
            
            let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
            let isPhotosSubmitted = PFUser.current()?.value(forKey: DBColumn.isPhotosSubmitted) as? Bool ?? false
            let isVideoSubmitted = PFUser.current()?.value(forKey: DBColumn.isVideoSubmitted) as? Bool ?? false
            
            self.isTrialPeriodExpired { (isExpired, daysLeft) in
                SVProgressHUD.dismiss()
                if isExpired {
                    if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
                        self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.uploadMediaFirst) { successAction in
                            let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: isExpired)
                            self.navigationController?.pushViewController(vc, animated: true)
                        } failureHandler: { failureAction in
                            
                        }
                    } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
                        self.navigationController?.pushViewController(WaitingVC(), animated: true)
                    } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                        let vc = PaymentVC(isTrialExpired: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
                        self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.uploadMediaFirst) { successAction in
                            let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: isExpired)
                            self.navigationController?.pushViewController(vc, animated: true)
                        } failureHandler: { failureAction in
                            
                        }
                    } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
                        self.showToast(message: ValidationStrings.profileUnderScreening)
                    } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                        let vc = PaymentVC(isTrialExpired: false)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        })
    }
    
    //MARK: - Button Actions
    @IBAction func profilePictureButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile)
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func payNowButtonPressed(_ sender: Any) {
        self.processUserState()
    }
    
    @IBAction func mandatoryQuestionnaireButtonPressed(_ sender: Any) {
        let isPaidUser = APP_MANAGER.session?.value(forKey: DBColumn.isPaidUser) as? Bool
        if isPaidUser ?? false {
            let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showToast(message: "You are not a paid user")
        }
    }
    
    @IBAction func optionalQuestionnaireButtonPressed(_ sender: Any) {
        let isPaidUser = APP_MANAGER.session?.value(forKey: DBColumn.isPaidUser) as? Bool
        if isPaidUser ?? false {
            let vc = QuestionnairesVC(isMandatoryQuestionnaires: false)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.showToast(message: "You are not a paid user")
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.logoutAlertMsg) { successAction in
            self.logoutUser()
        } failureHandler: { failureAction in
            
        }
    }
    
    @IBAction func photoVideoButtonPressed(_ sender: Any) {
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
