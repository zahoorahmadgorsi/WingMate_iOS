//
//  QuestionnairePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 08/11/2020.
//

import Foundation
import Parse
import SVProgressHUD

protocol QuestionnaireDelegate: class {
    func questionnaire(isSuccess: Bool, questionData: [Question], msg: String)
    func questionnaire(isSuccess: Bool, questionOptionsData: [Option], msg: String)
    func questionnaire(isSuccess: Bool, userSavedOptions: PFObject?, msg: String)
    func questionnaire(isSaved: Bool, msg: String)
    func questionnaire(isUpdated: Bool, msg: String)
}

class QuestionnairePresenter {
    
    weak var delegate: QuestionnaireDelegate?
    var dataQuestionnaire = [Question]()
    
    func attach(vc: QuestionnaireDelegate) {
        self.delegate = vc
    }
    
    func getQuestions(questionType: QuestionType) {
        SVProgressHUD.show()
        ParseAPIManager.getQuestions(questionType: questionType.rawValue) { (success, data) in
            if success {
                for obj in data {
                    let qs = Question(questionObject: obj)
                    self.dataQuestionnaire.append(qs)
                }
                self.delegate?.questionnaire(isSuccess: true, questionData: self.dataQuestionnaire, msg: "Questions fetched")
            } else {
                self.delegate?.questionnaire(isSuccess: false, questionData: [], msg: "No questions found")
            }
        } onFailure: { (error) in
            print(error)
            self.delegate?.questionnaire(isSuccess: false, questionData: [], msg: error)
        }
    }
    
    func getQuestionOptions(questionObject: PFObject, questionIndex: Int) {
        SVProgressHUD.show()
        ParseAPIManager.getQuestionOptions(questionObject: questionObject) { (success, data) in
            if success {
                for obj in data {
                    let qo = Option(questionOptionObject: obj)
                    self.dataQuestionnaire[questionIndex].options.append(qo)
                }
                self.delegate?.questionnaire(isSuccess: true, questionOptionsData: self.dataQuestionnaire[questionIndex].options, msg: "Options fetched")
            } else {
                self.delegate?.questionnaire(isSuccess: false, questionOptionsData: [], msg: "Question options not found")
            }
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSuccess: false, questionOptionsData: [], msg: error)
        }
    }
    
    func getUserSavedOptions(questionObject: PFObject, questionIndex: Int) {
        ParseAPIManager.getUserSavedOptions(questionObject: questionObject) { (sucess, data) in
            SVProgressHUD.dismiss()
            if sucess {
                if data.count > 0 {
                    self.dataQuestionnaire[questionIndex].userSavedOptionObject = data[0]
                }
                self.delegate?.questionnaire(isSuccess: true, userSavedOptions: self.dataQuestionnaire[questionIndex].userSavedOptionObject ?? nil, msg: "User saved options fetched")
            } else {
                self.delegate?.questionnaire(isSuccess: false, userSavedOptions: nil, msg: "No saved options found")
            }
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSuccess: false, userSavedOptions: nil, msg: error)
        }
    }
    
    func saveQuestionnaireOption(questionObject: PFObject, answersIds: [String], answersObjects: [PFObject]) {
        SVProgressHUD.show()
        ParseAPIManager.saveUserQuestionOptions(questionObject: questionObject, selectedOptionIds: answersIds, savedOptionsObjects: answersObjects) { (success, userAnswer) in
            SVProgressHUD.dismiss()
            self.delegate?.questionnaire(isSaved: true, msg: ValidationStrings.kQuestionnaireOptionSaved)
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSaved: false, msg: error)
        }
    }
    
    func updateUserOptions(userAnswerObject: PFObject) {
        SVProgressHUD.show()
        ParseAPIManager.updateUserQuestionOptions(object: userAnswerObject) { (isSuccess) in
            SVProgressHUD.dismiss()
            self.delegate?.questionnaire(isUpdated: true, msg: "Option updated")
        } onFailure: { (error) in
            self.delegate?.questionnaire(isUpdated: false, msg: error)
        }
    }
    
    func saveQuestionListInUserTable(data: Question) {
        
        let questionType = data.object?.value(forKey: DBColumn.questionType) as? String ?? ""
        var questionAnswerList = [PFObject]()
        if questionType == QuestionType.mandatory.rawValue {
            questionAnswerList = PFUser.current()?.value(forKey: DBColumn.mandatoryQuestionAnswersList) as? [PFObject] ?? []
            
        } else {
            questionAnswerList = PFUser.current()?.value(forKey: DBColumn.optionalQuestionAnswersList) as? [PFObject] ?? []
        }
        
        for i in 0..<questionAnswerList.count {
            do {
                let questionIdObj = try (questionAnswerList[i].fetchIfNeeded().value(forKey: DBColumn.questionId) as! PFObject)
                let questionId = questionIdObj.value(forKey: DBColumn.objectId) as? String ?? ""
//                try PFUser.current()?.fetchIfNeeded()
//                let questionId = questionAnswerList[i].value(forKey: DBColumn.questionId) as? String ?? ""
                let currentDataQuestionId = data.object?.value(forKey: DBColumn.objectId) as? String ?? ""
                if questionId == currentDataQuestionId {
                    questionAnswerList.remove(at: i)
                    break
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        questionAnswerList.append(data.userSavedOptionObject!)
        
        if questionType == QuestionType.mandatory.rawValue {
            PFUser.current()?.setValue(questionAnswerList, forKey: DBColumn.mandatoryQuestionAnswersList)
        } else {
            PFUser.current()?.setValue(questionAnswerList, forKey: DBColumn.optionalQuestionAnswersList)
        }
        
        SVProgressHUD.show()
        ParseAPIManager.updateUserObject() { (success) in
            SVProgressHUD.dismiss()
            if success {
//                APP_MANAGER.session = PFUser.current()
                print("Current user questionAnswersList updated")
            } else {
                print("Failed to update current user questionAnswersList")
            }
        } onFailure: { (error) in
            print("Failed to update current user questionAnswersList. Error: \(error)")
        }
        
    }
    
    
    
}
