//
//  EditProfileVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 16/01/2021.
//

import UIKit
import Parse

class EditProfileVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var tableViewQuestions: UITableView!
    @IBOutlet weak var cstHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var textViewAboutme: UITextView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldGender: UITextField!
    
    var presenter = EditProfilePresenter()
    var data: [UserProfileQuestion]?
    var userSavedOptions: [PFObject]?
    
    convenience init(userSavedOptions: [PFObject]) {
        self.init()
        self.userSavedOptions = userSavedOptions
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.setInitialLayout()
        self.tableViewQuestions.estimatedRowHeight = 40
        self.presenter.getQuestions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    //MARK: - Helping Methods
    func setInitialLayout() {
        self.textFieldName.text = APP_MANAGER.session?.value(forKey: DBColumn.nick) as? String ?? ""
        self.textViewAboutme.text = APP_MANAGER.session?.value(forKey: DBColumn.aboutMe) as? String ?? ""
        self.textFieldGender.text = APP_MANAGER.session?.value(forKey: DBColumn.gender) as? String ?? ""
    }
    
    func registerTableViewCells() {
        self.tableViewQuestions.register(UINib(nibName: EditProfileUserQuestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: EditProfileUserQuestionTableViewCell.className)
    }
    
    //MARK: - Button Actions
    @IBAction func aboutMeButtonPressed(_ sender: Any) {
        let vc = EditNameVC(isAboutmeEdit: true)
        vc.dataEdited = { [weak self] text in
            self?.textViewAboutme.text = text
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func genderButtonPressed(_ sender: Any) {
    }
    
    @IBAction func nickButtonPressed(_ sender: Any) {
        let vc = EditNameVC(isAboutmeEdit: false)
        vc.dataEdited = { [weak self] text in
            self?.textFieldName.text = text
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension EditProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileUserQuestionTableViewCell.className, for: indexPath) as! EditProfileUserQuestionTableViewCell
        cell.data = self.data?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
}

extension EditProfileVC: EditProfileDelegate {
    func editProfile(isSuccess: Bool, msg: String, questions: [PFObject]) {
        print(questions)
        if isSuccess {
            self.data = self.presenter.mapDataToModel(questions: questions , userSavedOptions: self.userSavedOptions ?? [])
            self.tableViewQuestions.reloadData {
                DispatchQueue.main.async {
                    self.cstHeightTableView.constant = self.tableViewQuestions.contentSize.height
                    self.tableViewQuestions.layoutIfNeeded()
                    self.cstHeightTableView.constant = self.tableViewQuestions.contentSize.height
                }
            }
        } else {
            self.showToast(message: msg)
        }
    }
}
