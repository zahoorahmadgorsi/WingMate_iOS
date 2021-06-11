//
//  CongratsVC.swift
//  WingMate_iOS
//
//  Created by mac on 11/06/2021.
//

import UIKit

class CongratsVC: BaseViewController {
    
    var isPhotosVideoUploadedFlow = false
    @IBOutlet weak var imageViewMain: UIImageView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!

    convenience init(isPhotosVideoUploadedFlow: Bool) {
        self.init()
        self.isPhotosVideoUploadedFlow = isPhotosVideoUploadedFlow
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isPhotosVideoUploadedFlow {
            self.labelHeading.text = "Thank you for uploading your Photo and Video!"
            self.labelSubHeading.text = "Please allow up to 24 hours for approval. Upon verification, we will send you an email and get you to the next step closer to being a Wingmate member! "
        }
    }

    @IBAction func continueButtonPressed(_ sender: Any) {
        if self.isPhotosVideoUploadedFlow {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
