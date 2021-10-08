//
//  QuestionIntroVC.swift
//  WingMate_iOS
//
//  Created by Anish on 9/13/21.
//

import UIKit

class QuestionIntroVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func continueAction(_ sender: UIButton) {
        let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    

}
