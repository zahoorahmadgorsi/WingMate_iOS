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
  //  @IBOutlet weak var payNowButton: UIButton!
    @IBOutlet weak var labelVersion: UILabel!

    var isLaunchCampaign = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            print("\(version).\(build)")
            self.labelVersion.text = "Version \(version).\(build)"
        }
        if let launchPay = UserDefaults.standard.object(forKey: UserDefaultKeys.userObjectKeyUserDefaults){
            self.isLaunchCampaign = launchPay as! Bool
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        if PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false == true {
           // self.payNowButton.isHidden = true
        } else {
           // self.payNowButton.isHidden = false
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
                self.showAlertOK(APP_NAME, message: ValidationStrings.kAccountRejected) { action in
                    self.logoutUser()
                }
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
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToWaitTrialExpired) { action in
                            self.navigationController?.pushViewController(WaitingVC(), animated: true)
                        }
                    } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToPayNowTrialExpired) { action in
                            if self.isLaunchCampaign == false {
                            let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                            }else {
                                let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
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
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToPayNow) { action in
                            if self.isLaunchCampaign == false {
                            let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                            }else {
                                let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
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
    
    
    
    @IBAction func changePassword(_ sender: Any) {
        let alert = UIAlertController(title: "Blinqui",
            message: "Type the email address you've used to sign up.\n(Please note that if you've signed in with Facebook, you will not be able to reset your password)",
            preferredStyle: .alert)
        
        let reset = UIAlertAction(title: "Reset Password", style: .default, handler: { (action) -> Void in
            // TextField
            let textField = alert.textFields!.first!
            let txtStr = textField.text!
            
            PFUser.requestPasswordResetForEmail(inBackground: txtStr, block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("Thanks, you are going to shortly get an email with a link to reset your password!")
            }})
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
        // Add textField
        alert.addTextField { (textField: UITextField) in
            textField.keyboardType = .default
            textField.autocorrectionType = .no
        }
        
        alert.addAction(reset)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func simpleAlert(_ mess:String) {
        let alert = UIAlertController(title: APP_NAME,
            message: mess, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    @IBAction func termsAndCondition(_ sender: Any) {
        if #available(iOS 13.0, *) {
            let vc = storyboard?.instantiateViewController(identifier: "tnc")
            self.present(vc!, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
       
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
