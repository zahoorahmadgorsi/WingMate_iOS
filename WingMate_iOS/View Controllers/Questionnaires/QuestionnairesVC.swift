//
//  QuestionnairesVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 26/10/2020.
//

import UIKit
import Parse
import UICircularProgressRing

class QuestionnairesVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var buttonSkip: UIButton!
    @IBOutlet weak var imageViewHeart: UIImageView!
    @IBOutlet weak var progressView: UICircularProgressRing!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var constraintTopSearchView: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightSearchView: NSLayoutConstraint!
    @IBOutlet weak var textFieldSearch: UITextField!
    
    var questionnairePresenter = QuestionnairePresenter()
    var data = [QuestionnaireNew]()
    var dataCopy = [QuestionnaireNew]()
    
    var questionIndex = 0
    var isMandatoryQuestionnaires = true
    var isFilterActivated = false
    
    convenience init(isMandatoryQuestionnaires: Bool) {
        self.init()
        self.isMandatoryQuestionnaires = isMandatoryQuestionnaires
    }
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionnairePresenter.attach(vc: self)
        self.setLayout()
        self.registerTableViewCells()
        if self.isMandatoryQuestionnaires {
            self.questionnairePresenter.getQuestions(questionType: .mandatory)
        } else {
            self.questionnairePresenter.getQuestions(questionType: .optional)
        }
    }
    
    //MARK: - Helping Methods
    func setLayout() {
        self.tableViewOptions.delegate = self
        self.tableViewOptions.dataSource = self
        self.buttonContinue.alpha = self.isMandatoryQuestionnaires ? 0.3 : 1
        self.buttonContinue.isEnabled = self.isMandatoryQuestionnaires ? false : true
        self.labelSubHeading.text = self.isMandatoryQuestionnaires ? ValidationStrings.kSelectOneBelowOption : ValidationStrings.kSelectMultipleBelowOption
        self.buttonSkip.isHidden = true
        self.progressView.isHidden = true
        self.labelSubHeading.isHidden = true
        self.imageViewHeart.isHidden = true
        self.buttonBack.isHidden = true
        self.buttonContinue.isHidden = true
        self.shouldShowSearchView(status: false)
    }
    
    func setInitialProgressView() {
        self.progressView.style = .ontop
        self.progressView.minValue = 1
        self.progressView.maxValue = CGFloat(self.data.count)
        self.progressView.startAngle = -90
        self.setProgress()
    }
    
    func shouldShowSearchView(status: Bool) {
        self.constraintTopSearchView.constant = status ? 40 : 0
        self.constraintHeightSearchView.constant = status ? 40 : 0
    }
    
    func setProgress() {
        self.labelProgress.text = "\(self.questionIndex+1)/\(self.data.count)"
        self.progressView.startProgress(to: CGFloat(self.questionIndex+1), duration: 0.1)
        if self.isMandatoryQuestionnaires && self.questionIndex == 2 {
            self.shouldShowSearchView(status: true)
        } else {
            self.shouldShowSearchView(status: false)
        }
//        self.data = self.dataCopy
    }
    
    func registerTableViewCells() {
        self.tableViewOptions.register(UINib(nibName: QuestionnaireSimpleOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireSimpleOptionTableViewCell.className)
        if self.isMandatoryQuestionnaires {
            self.tableViewOptions.register(UINib(nibName: QuestionnaireCountryOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireCountryOptionTableViewCell.className)
        }
    }
    
    func getOptions() {
        self.labelQuestion.text = self.data[self.questionIndex].questionObject?.value(forKey: DatabaseColumn.title) as? String ?? ""
        if self.data[self.questionIndex].questionOptionObjects.count == 0 { //if already fetched then don't fetch again
            self.questionnairePresenter.getQuestionOptions(questionObject: self.data[self.questionIndex].questionObject!, questionIndex: self.questionIndex)
        } else {
            self.mapAllSelectedValuesToMainData()
        }
    }
    
    func enableButtonIfAnyOptionIsMarked() {
        for i in self.data[self.questionIndex].questionOptionObjects {
            if i.isSelected == true {
                self.buttonContinue.alpha = 1
                self.buttonContinue.isEnabled = true
                return
            }
        }
    }
    
    func mapAllSelectedValuesToMainData() {
        for (i, dataMainItem) in self.dataCopy[self.questionIndex].questionOptionObjects.enumerated() {
            self.dataCopy[self.questionIndex].questionOptionObjects[i].isSelected = false
            for (j, dataItem) in self.data[self.questionIndex].questionOptionObjects.enumerated() {
                let objectIdDataItem = dataItem.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? ""
                let objectIdDataMainItem = dataMainItem.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? ""
                if (objectIdDataItem == objectIdDataMainItem) && (dataItem.isSelected) {
                    self.dataCopy[self.questionIndex].questionOptionObjects[i].isSelected = true
                }
            }
        }
        
//        for (i, dataItem) in self.dataCopy[self.questionIndex].questionOptionObjects.enumerated() {
//            for (j, dataMainItem) in self.data[self.questionIndex].questionOptionObjects.enumerated() {
//                let objectIdDataItem = dataItem.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? ""
//                let objectIdDataMainItem = dataMainItem.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? ""
//                if (objectIdDataItem == objectIdDataMainItem) && (dataItem.isSelected) {
//                    self.dataCopy[self.questionIndex].questionOptionObjects[j].isSelected = true
//                }
//            }
//        }
    }
    
    //MARK: - Button Actions
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        var answersIds = [String]()
        for i in self.data[self.questionIndex].questionOptionObjects {
            if i.isSelected {
                answersIds.append(i.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? "")
            }
        }
        if self.data[self.questionIndex].userSavedOptions != nil {
            //already saved, so update it
            if answersIds.count > 0 || self.isMandatoryQuestionnaires == false {
                let obj = self.data[self.questionIndex].userSavedOptions
                let userSavedOptions = obj?.value(forKey: DatabaseColumn.selectedOptionIds) as? [String]
                var isOptionsUpdated = false
                for i in self.data[self.questionIndex].questionOptionObjects {
                    if i.isSelected {
                        for j in userSavedOptions ?? [] {
                            if j != i.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? "" {
                                isOptionsUpdated = true
                                break
                            }
                        }
                    }
                }
                
                if isOptionsUpdated || self.isMandatoryQuestionnaires == false {
                    self.data[self.questionIndex].userSavedOptions?[DatabaseColumn.selectedOptionIds] = answersIds
                    self.questionnairePresenter.updateUserOptions(userAnswerObject: self.data[self.questionIndex].userSavedOptions!)
                } else {
                    self.moveToNextQuestion()
                }
            } else {
                self.showToast(message: ValidationStrings.kSelectAnyOption)
            }
        } else {
            //not saved, save it
            if answersIds.count > 0 {
                self.questionnairePresenter.saveQuestionnaireOption(questionObject: self.data[self.questionIndex].questionObject!, answersIds: answersIds)
            } else {
                self.showToast(message: ValidationStrings.kSelectAnyOption)
            }
        }
    }
    
    func moveToNextQuestion() {
        if self.questionIndex < self.data.count - 1 {
            self.questionIndex = self.questionIndex + 1
            self.getOptions()
            self.buttonContinue.alpha = self.isMandatoryQuestionnaires ? 0.3 : 1
            self.buttonContinue.isEnabled = self.isMandatoryQuestionnaires ? false : true
            self.enableButtonIfAnyOptionIsMarked()
            self.tableViewOptions.reloadData()
            
            //if optional questionnaires last question, then hide skip button
            if (self.questionIndex == self.data.count-1) && (self.isMandatoryQuestionnaires == false) {
                self.buttonSkip.isHidden = true
            }
            
            self.setProgress()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        if self.questionIndex == 0 {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.questionIndex = self.questionIndex - 1
            self.getOptions()
            self.buttonContinue.alpha = 1
            self.buttonContinue.isEnabled = true
            self.tableViewOptions.reloadData()
            if self.isMandatoryQuestionnaires == false {
                self.buttonSkip.isHidden = false
            }
            self.setProgress()
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        self.moveToNextQuestion()
    }
    
}

extension QuestionnairesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isMandatoryQuestionnaires && self.questionIndex == 2 {
            //country cell
            let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireCountryOptionTableViewCell.className, for: indexPath) as! QuestionnaireCountryOptionTableViewCell
//            let dta = self.isFilterActivated ? self.data[self.questionIndex].questionOptionObjects[indexPath.row] : self.dataCopy[self.questionIndex].questionOptionObjects[indexPath.row]
            cell.data = self.data[self.questionIndex].questionOptionObjects[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSimpleOptionTableViewCell.className, for: indexPath) as! QuestionnaireSimpleOptionTableViewCell
        cell.data = self.data[self.questionIndex].questionOptionObjects[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isMandatoryQuestionnaires {
            for (i, _) in self.data[self.questionIndex].questionOptionObjects.enumerated() {
                self.data[self.questionIndex].questionOptionObjects[i].isSelected = false
            }
            self.data[self.questionIndex].questionOptionObjects[indexPath.row].isSelected = true
            print("abc")
            if isFilterActivated {
                //map all data value to dataMain as well because once filter will be inactive it data will be replaced with dataMain to get all values
                self.mapAllSelectedValuesToMainData()
            }
        } else {
            self.data[self.questionIndex].questionOptionObjects[indexPath.row].isSelected = !self.data[self.questionIndex].questionOptionObjects[indexPath.row].isSelected
        }
        self.tableViewOptions.reloadData()
        self.buttonContinue.alpha = 1
        self.buttonContinue.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isMandatoryQuestionnaires && self.questionIndex == 2 {
            return 56 //country cell
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count > 0 ? self.data[self.questionIndex].questionOptionObjects.count : 0
    }
}

extension QuestionnairesVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isFilterActivated = true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.isFilterActivated = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchText  = self.textFieldSearch.text! + string
        if string == "" {
            if searchText.count > 0 {
                searchText.removeLast()
                if searchText.count == 0 {
                    self.textFieldSearch.text = ""
                    
                    self.data[self.questionIndex].questionOptionObjects = self.dataCopy[self.questionIndex].questionOptionObjects
                    self.view.endEditing(true)
                }
            }
        }

        if searchText.count == 0 {
//            self.data = self.dataCopy
            self.isFilterActivated = false
//            self.data[self.questionIndex].questionOptionObjects = self.dataCopy[self.questionIndex].questionOptionObjects
            self.tableViewOptions.reloadData()
        } else {
            self.isFilterActivated = true
            
            self.data[self.questionIndex].questionOptionObjects = self.dataCopy[self.questionIndex].questionOptionObjects.filter { dta in
                let isMatchingSearchText = (dta.questionOptionObject?.value(forKey: DatabaseColumn.title) as? String ?? "").lowercased().contains(searchText.lowercased())
                return isMatchingSearchText
            }
            
            self.tableViewOptions.reloadData()
        }
        return true
    }
}

extension QuestionnairesVC: QuestionnaireDelegate {
    //all questions response
    func questionnaire(isSuccess: Bool, questionData: [QuestionnaireNew], msg: String) {
        if isSuccess {
            self.data = questionData
            self.dataCopy = questionData
            self.setInitialProgressView()
            self.questionnairePresenter.getQuestionOptions(questionObject: self.data[self.questionIndex].questionObject!, questionIndex: self.questionIndex)
        } else {
            self.showToast(message: msg)
        }
    }
    
    //options response
    func questionnaire(isSuccess: Bool, questionOptionsData: [QuestionnaireNew], msg: String) {
        if isSuccess {
            self.data = questionOptionsData
            self.dataCopy = questionOptionsData
            self.questionnairePresenter.getUserSavedOptions(questionObject: self.data[self.questionIndex].questionObject!, questionIndex: self.questionIndex)
        } else {
            self.showToast(message: msg)
        }
    }
    
    //get user saved options response
    func questionnaire(isSuccess: Bool, userSavedOptions: [QuestionnaireNew], msg: String) {
        if isSuccess {
            if self.isMandatoryQuestionnaires == false {
                self.buttonSkip.isHidden = false
            }
            self.data = userSavedOptions
            self.dataCopy = userSavedOptions
            let optionsArray = self.data[questionIndex].userSavedOptions?.value(forKey: DatabaseColumn.selectedOptionIds) as? [String]
            
            for (i, item) in self.data[self.questionIndex].questionOptionObjects.enumerated() {
                for j in optionsArray ?? [] {
                    let questionOptionId = item.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? ""
                    let userSelectedOptionId = j
                    if questionOptionId == userSelectedOptionId {
                        self.buttonContinue.alpha = 1
                        self.buttonContinue.isEnabled = true
                        self.data[self.questionIndex].questionOptionObjects[i].isSelected = true
//                        i.isSelected = true
                    }
                }
            }
            
            self.mapAllSelectedValuesToMainData()
            
            self.labelQuestion.text = self.data[self.questionIndex].questionObject?.value(forKey: DatabaseColumn.title) as? String ?? ""
            
            self.tableViewOptions.reloadData()
            self.progressView.isHidden = false
            self.labelSubHeading.isHidden = false
            if (self.questionIndex == self.data.count-1) && (self.isMandatoryQuestionnaires == false) {
                self.buttonSkip.isHidden = true
            }
            self.imageViewHeart.isHidden = false
            self.buttonBack.isHidden = false
            self.buttonContinue.isHidden = false
            
        } else {
            self.showToast(message: msg)
        }
    }
    
    //user option saved response
    func questionnaire(isSaved: Bool, msg: String) {
        if isSaved {
            self.moveToNextQuestion()
            //            self.showToast(message: msg)
        } else {
            self.showToast(message: msg)
        }
    }
    
    func questionnaire(isUpdated: Bool, msg: String) {
        if isUpdated {
            self.moveToNextQuestion()
            //            self.showToast(message: msg)
        } else {
            self.showToast(message: msg)
        }
    }
}

struct QuestionnaireNew {
    var questionObject: PFObject?
    var questionOptionObjects = [QuestionnaireOptionNew]()
    var userSavedOptions: PFObject?
    init() {}
    init(questionObject: PFObject) {
        self.questionObject = questionObject
    }
}

struct QuestionnaireOptionNew {
    var isSelected = false
    var questionOptionObject: PFObject?
    
    init() {}
    init(questionOptionObject: PFObject) {
        self.questionOptionObject = questionOptionObject
    }
}
