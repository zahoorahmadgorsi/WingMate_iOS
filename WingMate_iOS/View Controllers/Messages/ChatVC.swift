//
//  ChatVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 16/02/2021.
//

import UIKit

class ChatVC: BaseViewController {

    @IBOutlet weak var imageViewProfile: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        
        if self.isTimeExpiredToRecallAPIs() {
            self.checkAccountStatus()
        } else {
            print("not expired")
        }
    }
    
    //MARK: - Button Actions
    @IBAction func profilePictureButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile)
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
