//
//  QuestionnairesVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 26/10/2020.
//

import UIKit

class QuestionnairesVC: BaseViewController {

    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var tableViewOptions: UITableView!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    
    var questionIndex = 0
    var isMandatoryQuestionnaires = true
    
    var data: [Questionnaire] = [
        Questionnaire(question: "We know age is just a number?", options: [
                        Option(title: "21 - 26"),
                        Option(title: "27 - 32"),
                        Option(title: "33 - 38"),
                        Option(title: "39 - 44"),
                        Option(title: "45 - 50"),
                        Option(title: "51 and above")]),
        Questionnaire(question: "How far is your head from feet?", options: [
                        Option(title: "< 1.50cm"),
                        Option(title: "1.50cm - 1.60cm"),
                        Option(title: "1.61cm - 1.70cm"),
                        Option(title: "1.71cm - 1.80cm"),
                        Option(title: "1.81cm - 1.90cm"),
                        Option(title: "1.90cm <")]),
        Questionnaire(question: "Where is home for you?", options: [
                        Option(title: "United Arab Emirates", flagImage: "uae-flag"),
                        Option(title: "Saudi Arabia", flagImage: "ksa-flag"),
                        Option(title: "Bahrain", flagImage: "bahrain-flag")]),
        Questionnaire(question: "What are you looking for?", options: [
                        Option(title: "Looking for serious fun"),
                        Option(title: "In the meantime"),
                        Option(title: "Looking for likeminded friends"),
                        Option(title: "Looking for serious relationship")])
        ]
    
    //MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewOptions.delegate = self
        self.tableViewOptions.dataSource = self
        self.buttonContinue.alpha = 0.3
        self.buttonContinue.isEnabled = false
        self.registerTableViewCells()
        self.setQuestion()
    }
    
    //MARK: - Helping Methods
    func registerTableViewCells() {
        self.tableViewOptions.register(UINib(nibName: QuestionnaireSimpleOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireSimpleOptionTableViewCell.className)
        if self.isMandatoryQuestionnaires {
            self.tableViewOptions.register(UINib(nibName: QuestionnaireCountryOptionTableViewCell.className, bundle: nil), forCellReuseIdentifier: QuestionnaireCountryOptionTableViewCell.className)
        }
    }
    
    func setQuestion() {
        self.labelQuestion.text = self.data[self.questionIndex].question
    }
    
    func enableButtonIfAnyOptionIsMarked() {
        for i in self.data[self.questionIndex].options {
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
            self.questionIndex = self.questionIndex + 1
            self.setQuestion()
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
            self.setQuestion()
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
            cell.data = self.data[self.questionIndex].options[indexPath.row]
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSimpleOptionTableViewCell.className, for: indexPath) as! QuestionnaireSimpleOptionTableViewCell
        cell.data = self.data[self.questionIndex].options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        for i in self.data[self.questionIndex].options {
            i.isSelected = false
        }
        self.data[self.questionIndex].options[indexPath.row].isSelected = true
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
        return self.data[self.questionIndex].options.count
    }
}

class Questionnaire {
    var question = ""
    var options = [Option]()
    var selectedAnswerIndex = -1
    
    init(question: String, options: [Option]) {
        self.question = question
        self.options = options
    }
}

class Option {
    var title = ""
    var flagImage: String?
    var isSelected = false
    
    init(title: String, flagImage: String? = "") {
        self.title = title
        self.flagImage = flagImage
    }
}
