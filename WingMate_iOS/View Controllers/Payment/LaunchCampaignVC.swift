//
//  LaunchCampaignVC.swift
//  WingMate_iOS
//
//  Created by Anish on 9/13/21.
//

import UIKit
import Parse
import SVProgressHUD

class LaunchCampaignVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        PFUser.current()?.setValue(true, forKey: DBColumn.isPaidUser)
        SVProgressHUD.show()
        ParseAPIManager.updateUserObject() { (success) in
            SVProgressHUD.dismiss()
            if success {
                APP_MANAGER.session = PFUser.current()
                let vc = QuestionIntroVC(nibName: "QuestionIntroVC", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showToast(message: "Failed to update to paid user")
            }
        } onFailure: { (error) in
            self.showToast(message: error)
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
