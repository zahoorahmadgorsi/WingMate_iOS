//
//  DecideLoginRegisterVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 17/10/2020.
//

import UIKit

class DecideLoginRegisterVC: UIViewController {

    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Button Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(LoginVC(), animated: true)
    }
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        
    }
}
