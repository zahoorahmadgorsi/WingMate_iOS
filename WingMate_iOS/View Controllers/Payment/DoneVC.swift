//
//  DoneVC.swift
//  WingMate_iOS
//
//  Created by Anish on 9/13/21.
//

import UIKit

class DoneVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    @IBAction func continueAction(_ sender: UIButton) {
        
        let vc = QuestionIntroVC(nibName: "QuestionIntroVC", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
 

}
