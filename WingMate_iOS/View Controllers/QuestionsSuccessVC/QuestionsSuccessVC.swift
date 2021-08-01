//
//  QuestionsSuccessVC.swift
//  WingMate_iOS
//
//  Created by mac on 31/07/2021.
//

import UIKit
import Parse

class QuestionsSuccessVC: BaseViewController {
    
    var isPhotosVideoUploadedFlow = false
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var buttonSkip: UIButton!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    var isMandatorySuccess = true

    convenience init(isMandatorySuccess: Bool) {
        self.init()
        self.isMandatorySuccess = isMandatorySuccess
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isMandatorySuccess {
            self.labelHeading.text = "You're almost done!\nOnly 5 more questions left"
            self.labelSubHeading.text = "If you are curious to know your compatibility score, please take a minute to answer the next 5 questions"
            self.imageViewMain.image = UIImage(named: "mandatory_success")
        } else {
            self.buttonSkip.isHidden = true
            self.labelHeading.text = "You're all setup!\nReady for action"
            self.labelSubHeading.text = "Thanks for completing your profile"
            self.imageViewMain.image = UIImage(named: "optional_success")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    @IBAction func continueButtonPressed(_ sender: Any) {
        if self.isMandatorySuccess {
            let vc = QuestionnairesVC(isMandatoryQuestionnaires: false)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
