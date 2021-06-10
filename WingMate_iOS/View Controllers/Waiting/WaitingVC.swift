//
//  WaitingVC.swift
//  WingMate_iOS
//
//  Created by mac on 10/06/2021.
//

import UIKit

class WaitingVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        ParseAPIManager.logoutUser { (success) in
            APP_MANAGER.session = nil
//            self.navigationController?.popToRootViewController(animated: true)
            let vc = PreLoginVC()
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.navigationBar.isHidden = true
            APP_DELEGATE.window?.rootViewController = navigationController
        } onFailure: { (error) in
            self.showToast(message: error)
        }
    }

}
