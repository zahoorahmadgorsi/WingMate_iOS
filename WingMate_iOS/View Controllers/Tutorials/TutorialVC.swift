//
//  TutorialVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 12/11/2020.
//

import UIKit

class TutorialVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var buttonContinue: UIButton!
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Helper Methods
    
    //MARK: - Button Actions
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(RegisterStepOneVC(), animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
