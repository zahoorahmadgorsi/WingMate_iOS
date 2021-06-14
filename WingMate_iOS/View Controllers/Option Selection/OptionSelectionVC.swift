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
    
    @IBOutlet weak var viewBgMale: UIView!
    @IBOutlet weak var labelMale: UILabel!
    @IBOutlet weak var viewBgFemale: UIView!
    @IBOutlet weak var labelFemale: UILabel!
    
    var isFilterActivated = false
    var isGenderQuestion = false
    var selectedGender: Gender?
    var data = Question()
    var dataCopy = Question()
    var isSearchFlow = false

    var presenter = OptionSelectionPresenter()
    var userAnswerUpdated: ((PFObject) -> Void )?
    var isGenderUpdated: ((Bool)-> Void)?
    
    convenience init(userProfileData: UserProfileQuestion, isSearchFlow: Bool) {
        self.init()
        self.isSearchFlow = isSearchFlow
        self.data.object = userProfileData.questionObject
        let options = userProfileData.questionObject?.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
        for i in options {
            self.data.options.append(Option(questionOptionObject: i))
        }
        let userSelectedAnswers = userProfileData.userAnswerObject?.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
        for (i, questionOption) in options.enumerated() {
            let optionId = questionOption.value(forKey: DBColumn.objectId) as? String ?? ""
            for (_, userOption) in userSelectedAnswers.enumerated() {
                let userSelectedOptionId = userOption.value(forKey: DBColumn.objectId) as? String ?? ""
                if optionId == userSelectedOptionId {
                    self.data.options[i].isSelected = true
                    break
                }
            }
        }
        self.data.userSavedOptionObject = userProfileData.userAnswerObject
        self.dataCopy = self.data
    }
    
    convenience init(isGenderQuestion: Bool) {
        self.init()
        self.isGenderQuestion = isGenderQuestion
    }
    
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.registerTableViewCells()
        self.presenter.attach(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: - Helping Methods
    func setLayout() {
        if self.isGenderQuestion {
            self.viewBgMale.isHidden = false
            self.viewBgMale.isHidden = false
            self.tableViewOptions.isHidden = true
            self.labelQuestion.text = "Gender"
            let gender = APP_MANAGER.session?.value(forKey: DBColumn.gender) as? String ?? ""
            self.selectedGender = gender == "Male" ? .male : .female
            self.setGenderViews()
            self.shouldShowSearchView(status: false)
        } else {
            self.viewBgMale.isHidden = true
            self.viewBgFemale.isHidden = true
            self.tableViewOptions.isHidden = false
            self.labelSubHeading.text = self.presenter.isMandatoryQuestion(data: self.data.object!) ? ValidationStrings.kSelectOneBelowOption : ValidationStrings.kSelectMultipleBelowOption
            self.labelQuestion.text = self.data.object?.value(forKey: DBColumn.shortTitle) as? String ?? ""
            
            if (self.data.object?.value(forKey: DBColumn.objectId) as? String ?? "") == APP_MANAGER.countryQuestionId {
                self.shouldShowSearchView(status: true)
            } else {
                self.shouldShowSearchView(status: false)
            }
        }
        
    }
    
    func shouldShowSearchView(status: Bool) {
        self.constraintTopSearchView.constant = status ? 20 : 0
        self.constraintHeightSearchView.constant = status ? 40 : 0
    }
    
    func registerTableViewCells() {
        self.tableViewOptions.register(UINib(nibName: QuestionnaireSimpleOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireSimpleOptionTableViewCell.className)
        self.tableViewOptions.register(UINib(nibName: QuestionnaireCountryOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireCountryOptionTableViewCell.className)
    }
    
    func setGenderViews() {
        if self.selectedGender == .male {
            self.viewBgFemale.backgroundColor = UIColor.appThemeYellowColor
            self.labelFemale.textColor = UIColor.appThemePurpleColor
            self.viewBgMale.backgroundColor = UIColor.appThemeRedColor
            self.labelMale.textColor = UIColor.white
        } else {
            self.viewBgMale.backgroundColor = UIColor.appThemeYellowColor
            self.labelMale.textColor = UIColor.appThemePurpleColor
            self.viewBgFemale.backgroundColor = UIColor.appThemeRedColor
            self.labelFemale.textColor = UIColor.white
        }
    }
    
    func mapValuesToMainData() {
        for i in data.options {
            if i.isSelected {
                for (j, item) in dataCopy.options.enumerated() {
                    if item.object?.value(forKey: DBColumn.objectId) as? String ?? "" == i.object?.value(forKey: DBColumn.objectId) as? String ?? "" {
                        self.dataCopy.options[j].isSelected = true
                        break
                    }
                }
                break
            }
        }
    }
    
    //MARK: - Button Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        if self.isSearchFlow {
            var answersIds = [String]()
            var answersObjects = [PFObject]()
            for i in self.data.options {
                if i.isSelected {
                    answersIds.append(i.object?.value(forKey: DBColumn.objectId) as? String ?? "")
                    answersObjects.append(i.object!)
                }
            }
            let userAnswer = PFObject(className: DBTable.userAnswer)
            userAnswer[DBColumn.userId] = ApplicationManager.shared.session
            userAnswer[DBColumn.questionId] = self.data.object
            userAnswer[DBColumn.selectedOptionIds] = answersIds
            userAnswer[DBColumn.optionsObjArray] = answersObjects
            self.userAnswerUpdated?(userAnswer)
            self.dismiss(animated: true, completion: nil)
        } else {
            if self.isGenderQuestion {
                self.presenter.updateGender(text: self.selectedGender!.rawValue)
            } else {
                var answersIds = [String]()
                var answersObjects = [PFObject]()
                for i in self.data.options {
                    if i.isSelected {
                        answersIds.append(i.object?.value(forKey: DBColumn.objectId) as? String ?? "")
                        answersObjects.append(i.object!)
                    }
                }
                
                if self.data.userSavedOptionObject == nil {
                    //save
                    self.presenter.saveUserOptions(questionObject: self.data.object!, answersIds: answersIds, answersObjects: answersObjects)
                } else {
                    //update
                    self.data.userSavedOptionObject?[DBColumn.selectedOptionIds] = answersIds
                    self.data.userSavedOptionObject?[DBColumn.optionsObjArray] = answersObjects
                    self.presenter.updateUserOptions(userAnswerObject: self.data.userSavedOptionObject!)
                }
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func maleButtonPressed(_ sender: Any) {
        self.selectedGender = .male
        self.setGenderViews()
    }
    
    @IBAction func femaleButtonPressed(_ sender: Any) {
        self.selectedGender = .female
        self.setGenderViews()
    }
}

extension OptionSelectionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.data.object?.value(forKey: DBColumn.objectId) as? String ?? "") == APP_MANAGER.countryQuestionId { //country question object id
            let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireCountryOptionTableViewCell.className, for: indexPath) as! QuestionnaireCountryOptionTableViewCell
            cell.data = self.data.options[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSimpleOptionTableViewCell.className, for: indexPath) as! QuestionnaireSimpleOptionTableViewCell
//        cell.isUserSelectedOption = self.presenter.isSelectedOption(option: self.options[indexPath.row], userAnswerObject: self.data?.userAnswerObject)
//        cell.dataOption = self.options[indexPath.row]
        cell.data = self.data.options[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isSearchFlow {
            self.data.options[indexPath.row].isSelected = !self.data.options[indexPath.row].isSelected
            self.mapValuesToMainData()
        } else {
            if self.presenter.isMandatoryQuestion(data: self.data.object!) {
                for (i, _) in self.data.options.enumerated() {
                    self.data.options[i].isSelected = false
                }
                for (i, _) in self.dataCopy.options.enumerated() {
                    self.dataCopy.options[i].isSelected = false
                }
                self.data.options[indexPath.row].isSelected = true
                self.mapValuesToMainData()
            } else {
                self.data.options[indexPath.row].isSelected = !self.data.options[indexPath.row].isSelected
            }
        }
        self.tableViewOptions.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (self.data.object?.value(forKey: DBColumn.objectId) as? String ?? "") == APP_MANAGER.countryQuestionId {
            return 56 //country cell
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.options.count
    }
}

extension OptionSelectionVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isFilterActivated = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isFilterActivated = false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText  = self.textFieldSearch.text! + string
        if string == "" && searchText.count == 1 {
            self.textFieldSearch.text = ""
            self.data.options = self.dataCopy.options
            self.isFilterActivated = false
            self.view.endEditing(true)
        } else {
            self.isFilterActivated = true
            self.data.options = self.dataCopy.options.filter { dta in
                let isMatchingSearchText = (dta.object?.value(forKey: DBColumn.title) as? String ?? "").lowercased().contains(searchText.lowercased())
                return isMatchingSearchText
            }
        }
        self.tableViewOptions.reloadData()
        return true
    }
}

extension OptionSelectionVC: OptionSelectionDelegate {
    func optionSelection(isSuccess: Bool, msg: String, updatedUserAnswerObject: PFObject) {
        self.showToast(message: msg)
        if isSuccess {
            self.userAnswerUpdated?(updatedUserAnswerObject)
            self.dismiss(animated: true, completion: nil)
        }
    }
    func optionSelection(isSuccess: Bool, msg: String) {
        self.showToast(message: msg)
        if isSuccess {
            self.isGenderUpdated?(true)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
