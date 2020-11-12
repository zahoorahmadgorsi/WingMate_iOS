//
//  QuestionnairesVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 26/10/2020.
//

import UIKit
import Parse

class QuestionnairesVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    
    var questionnairePresenter = QuestionnairePresenter()
    var data = [QuestionnaireNew]()
    
    var questionIndex = 0
    var isMandatoryQuestionnaires = true
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionnairePresenter.attach(vc: self)
        self.setLayout()
        self.registerTableViewCells()
//        self.setQuestion()
        if self.isMandatoryQuestionnaires {
            self.questionnairePresenter.getAllQuestions(questionType: .mandatory)
        } else {
            self.questionnairePresenter.getAllQuestions(questionType: .optional)
        }
    }
    
    //MARK: - Helping Methods
    func setLayout() {
        self.tableViewOptions.delegate = self
        self.tableViewOptions.dataSource = self
        self.buttonContinue.alpha = 0.3
        self.buttonContinue.isEnabled = false
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
            self.questionnairePresenter.getAllOptionsOfQuestion(questionObject: self.data[self.questionIndex].questionObject!, questionIndex: self.questionIndex)
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
    
    //MARK: - Button Actions
    @IBAction func continueButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        if self.questionIndex < self.data.count - 1 {
            var answersIds = [String]()
            for i in self.data[self.questionIndex].questionOptionObjects {
                if i.isSelected {
                    answersIds.append(i.questionOptionObject?.value(forKey: DatabaseColumn.objectId) as? String ?? "")
                }
            }
            ParseAPIManager.saveUserQuestionnaireOption(questionObject: self.data[self.questionIndex].questionObject!, selectedOptionIds: answersIds) { (success) in
                print(success)
            } onFailure: { (error) in
                print(error)
            }

            
            self.questionIndex = self.questionIndex + 1
            self.getOptions()
            self.buttonContinue.alpha = 0.3
            self.buttonContinue.isEnabled = false
            self.enableButtonIfAnyOptionIsMarked()
            self.tableViewOptions.reloadData()
        } else {
            print("questions complete")
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
        }
    }
    
}

extension QuestionnairesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isMandatoryQuestionnaires && self.questionIndex == 2 {
            //country cell
            let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireCountryOptionTableViewCell.className, for: indexPath) as! QuestionnaireCountryOptionTableViewCell
//            cell.data = self.dataold[self.questionIndex].options[indexPath.row]
            cell.data = self.data[self.questionIndex].questionOptionObjects[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSimpleOptionTableViewCell.className, for: indexPath) as! QuestionnaireSimpleOptionTableViewCell
        cell.data = self.data[self.questionIndex].questionOptionObjects[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in self.data[self.questionIndex].questionOptionObjects {
            i.isSelected = false
        }
        self.data[self.questionIndex].questionOptionObjects[indexPath.row].isSelected = true
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

extension QuestionnairesVC: QuestionnaireDelegate {
    func questionnaire(isSuccess: Bool, questionData: [QuestionnaireNew], msg: String) {
        if isSuccess {
            self.data = questionData
//            self.showToast(message: msg)
            self.questionnairePresenter.getAllOptionsOfQuestion(questionObject: self.data[self.questionIndex].questionObject!, questionIndex: self.questionIndex)
        } else {
            self.showToast(message: msg)
        }
    }
    
    func questionnaire(isSuccess: Bool, questionOptionsData: [QuestionnaireNew], msg: String) {
        if isSuccess {
            self.data = questionOptionsData
            self.labelQuestion.text = self.data[self.questionIndex].questionObject?.value(forKey: DatabaseColumn.title) as? String ?? ""
            self.showToast(message: msg)
            self.tableViewOptions.reloadData()
            print(questionOptionsData)
        } else {
            self.showToast(message: msg)
        }
    }
}

class QuestionnaireNew {
    var questionObject: PFObject?
    var questionOptionObjects = [QuestionnaireOptionNew]()
    init() {}
    init(questionObject: PFObject) {
        self.questionObject = questionObject
    }
}

class QuestionnaireOptionNew {
    var isSelected = false
    var questionOptionObject: PFObject?
    init() {}
    init(questionOptionObject: PFObject) {
        self.questionOptionObject = questionOptionObject
    }
}
