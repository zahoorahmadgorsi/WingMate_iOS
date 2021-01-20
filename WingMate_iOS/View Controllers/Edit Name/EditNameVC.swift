//
//  EditNameVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 20/01/2021.
//

import UIKit

class EditNameVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelSubHeading: UILabel!
    @IBOutlet weak var textFieldNickName: UITextField!
    @IBOutlet weak var textViewAboutMe: UITextView!
    var isAboutmeEdit = false
    var dataEdited: ((String)-> Void)?
    
    convenience init(isAboutmeEdit: Bool) {
        self.init()
        self.isAboutmeEdit = isAboutmeEdit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setInitialLayout()
    }
    
    func setInitialLayout() {
        self.labelSubHeading.text = self.isAboutmeEdit ? "About Me" : "Name or Nick Name"
        self.textFieldNickName.isHidden = self.isAboutmeEdit ? true : false
        self.textViewAboutMe.isHidden = self.isAboutmeEdit ? false : true
        self.textFieldNickName.text = APP_MANAGER.session?.value(forKey: DBColumn.nick) as? String ?? ""
        self.textViewAboutMe.text = APP_MANAGER.session?.value(forKey: DBColumn.aboutMe) as? String ?? ""
    }
    
    //MARK: - Button Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        if self.isAboutmeEdit {
            if self.textViewAboutMe.text == "" {
                self.showToast(message: "Enter any text to save")
            } else {
                self.dataEdited!(self.textViewAboutMe.text!)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            if self.textFieldNickName.text == "" {
                self.showToast(message: "Enter any text to save")
            } else {
                self.dataEdited!(self.textFieldNickName.text!)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
