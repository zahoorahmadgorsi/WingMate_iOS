//
//  OptionSelectionVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/01/2021.
//

import UIKit
import Parse

class OptionSelectionVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var constraintHeightSearchView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSearchView: NSLayoutConstraint!
    @IBOutlet weak var textFieldSearch: UITextField!
    
    var isFilterActivated = false
    var data: UserProfileQuestion?
    var options = [PFObject]()
    var presenter = OptionSelectionPresenter()
    
    convenience init(data: UserProfileQuestion) {
        self.init()
        self.data = data
        self.options = self.data?.questionObject?.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
    }
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.registerTableViewCells()
        self.presenter.attach(vc: self)
    }
    
    //MARK: - Helping Methods
    func setLayout() {
        self.labelSubHeading.text = self.data?.questionObject?.value(forKey: DBColumn.questionType) as? String ?? "" == QuestionType.mandatory.rawValue ? ValidationStrings.kSelectOneBelowOption : ValidationStrings.kSelectMultipleBelowOption
        self.labelQuestion.text = self.data?.questionObject?.value(forKey: DBColumn.shortTitle) as? String ?? ""
        self.shouldShowSearchView(status: false)
    }
    
    func shouldShowSearchView(status: Bool) {
        self.constraintTopSearchView.constant = status ? 20 : 0
        self.constraintHeightSearchView.constant = status ? 40 : 0
    }
    
    func registerTableViewCells() {
        self.tableViewOptions.register(UINib(nibName: QuestionnaireSimpleOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireSimpleOptionTableViewCell.className)
        self.tableViewOptions.register(UINib(nibName: QuestionnaireCountryOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireCountryOptionTableViewCell.className)
    }
    
    //MARK: - Button Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension OptionSelectionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.data?.questionObject?.value(forKey: DBColumn.objectId) as? String ?? "") == APP_MANAGER.countryQuestionId { //country question object id
            //country cell
            let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireCountryOptionTableViewCell.className, for: indexPath) as! QuestionnaireCountryOptionTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSimpleOptionTableViewCell.className, for: indexPath) as! QuestionnaireSimpleOptionTableViewCell
        cell.isUserSelectedOption = self.presenter.isSelectedOption()
        cell.dataOption = self.options[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.data?.questionObject?.value(forKey: DBColumn.objectId) as? String ?? "") == APP_MANAGER.countryQuestionId {
            return 56 //country cell
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
}

extension OptionSelectionVC: OptionSelectionDelegate {
    func optionSelection() {
        
    }
}
