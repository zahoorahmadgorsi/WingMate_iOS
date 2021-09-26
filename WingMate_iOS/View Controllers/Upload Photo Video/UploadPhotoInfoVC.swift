//
//  UploadPhotoInfoVC.swift
//  WingMate_iOS
//
//  Created by Anish on 9/12/21.
//

import UIKit

class UploadPhotoInfoVC: UIViewController {

    var isExpired = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func `continue`(_ sender: Any) {
         let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: isExpired)
         self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
