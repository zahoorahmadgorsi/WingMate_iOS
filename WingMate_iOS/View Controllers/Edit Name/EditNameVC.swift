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
    var presenter = EditNamePresenter()
    
    convenience init(isAboutmeEdit: Bool) {
        self.init()
        self.isAboutmeEdit = isAboutmeEdit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.setInitialLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.checkAccountStatus()
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
                self.presenter.updateNickOrAboutme(text: self.textViewAboutMe.text!, isAboutme: true)
            }
        } else {
            if self.textFieldNickName.text == "" {
                self.showToast(message: "Enter any text to save")
            } else {
                self.presenter.updateNickOrAboutme(text: self.textFieldNickName.text!, isAboutme: false)
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditNameVC: EditNameDelegate {
    func editName(isSuccess: Bool, msg: String) {
        self.showToast(message: msg)
        if isSuccess {
            self.view.endEditing(true)
            if self.isAboutmeEdit {
                self.dataEdited!(APP_MANAGER.session?.value(forKey: DBColumn.aboutMe) as? String ?? "")
            } else {
                self.dataEdited!(APP_MANAGER.session?.value(forKey: DBColumn.nick) as? String ?? "")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}
