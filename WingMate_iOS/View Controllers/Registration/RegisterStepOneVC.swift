//
//  RegisterStepOneVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/10/2020.
//

import UIKit

class RegisterStepOneVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var imageViewPlaceholderVideo: UIImageView!
    @IBOutlet weak var textViewInfo: UITextView!
    
    //MARK: - View Controller Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
    }
    
    //MARK: - Helper Methods
    func setLayout() {
        
    }
    
    //MARK: - Button Actions
    @IBAction func playVideoButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(RegisterStepTwoVC(), animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}
