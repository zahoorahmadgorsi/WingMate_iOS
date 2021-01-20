//
//  EditProfileSelectionViewController.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/01/2021.
//

import UIKit
import Parse

class EditProfileSelectionVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSkip: UIButton!
    @IBOutlet weak var constraintHeightSearchView: NSLayoutConstraint!
    @IBOutlet weak var constraintTopSearchView: NSLayoutConstraint!
    @IBOutlet weak var textFieldSearch: UITextField!
    
    var isFilterActivated = false
    var data: UserProfileQuestion?
    
    convenience init(data: UserProfileQuestion) {
        self.init()
        self.data = data
    }
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.registerTableViewCells()
    }
    
    //MARK: - Helping Methods
    func setLayout() {
//        self.tableViewOptions.delegate = self
//        self.tableViewOptions.dataSource = self
//        self.labelSubHeading.text = self.isMandatoryQuestionnaires ? ValidationStrings.kSelectOneBelowOption : ValidationStrings.kSelectMultipleBelowOption
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
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
}

//extension EditProfileSelectionVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if (self.data?.questionObject?.value(forKey: DBColumn.objectId) as? String ?? "") == "C5dYcH5GNx" { //country question object id
//            //country cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireCountryOptionTableViewCell.className, for: indexPath) as! QuestionnaireCountryOptionTableViewCell
//            return cell
//        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSimpleOptionTableViewCell.className, for: indexPath) as! QuestionnaireSimpleOptionTableViewCell
//        cell.data = self.filteredData[self.questionIndex].options[indexPath.row]
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if self.isMandatoryQuestionnaires {
//            for i in 0..<self.filteredData[self.questionIndex].options.count {
//                self.filteredData[self.questionIndex].options[i].isSelected = false
//            }
//            for i in 0..<self.mainData[self.questionIndex].options.count {
//                self.mainData[self.questionIndex].options[i].isSelected = false
//            }
//            self.filteredData[self.questionIndex].options[indexPath.row].isSelected = true
//            self.mapValuesToMainData()
//        } else {
//            self.filteredData[self.questionIndex].options[indexPath.row].isSelected = !self.filteredData[self.questionIndex].options[indexPath.row].isSelected
//        }
//        self.tableViewOptions.reloadData()
//        self.buttonContinue.alpha = 1
//        self.buttonContinue.isEnabled = true
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if self.isMandatoryQuestionnaires && self.questionIndex == 2 {
//            return 56 //country cell
//        }
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.filteredData.count > 0 ? self.filteredData[self.questionIndex].options.count : 0
//    }
//}
