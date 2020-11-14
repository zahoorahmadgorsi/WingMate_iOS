//
//  QuestionnairePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 08/11/2020.
//

import Foundation
import Parse
import SVProgressHUD

protocol QuestionnaireDelegate {
    func questionnaire(isSuccess: Bool, questionData: [QuestionnaireNew], msg: String)
    func questionnaire(isSuccess: Bool, questionOptionsData: [QuestionnaireNew], msg: String)
    func questionnaire(isSuccess: Bool, userSavedOptions: [QuestionnaireNew], msg: String)
    func questionnaire(isSaved: Bool, msg: String)
    func questionnaire(isUpdated: Bool, msg: String)
}

class QuestionnairePresenter {
    
    var delegate: QuestionnaireDelegate?
    var dataQuestionnaire = [QuestionnaireNew]()
    
    func attach(vc: QuestionnaireDelegate) {
        self.delegate = vc
    }
    
    func getAllQuestions(questionType: QuestionType) {
        SVProgressHUD.show()
        ParseAPIManager.getAllData(from: DatabaseTable.question, whereKeyName: DatabaseColumn.questionType, whereKeyValue: questionType.rawValue, orderByKey: DatabaseColumn.displayOrder, isWhereKeyObjectType: false) { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                for obj in data {
                    let qs = QuestionnaireNew(questionObject: obj)
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
    
    func getAllOptionsOfQuestion(questionObject: PFObject, questionIndex: Int) {
        SVProgressHUD.show()
        ParseAPIManager.getAllData(from: DatabaseTable.questionOption, whereKeyName: DatabaseColumn.questionId, whereKeyObject: questionObject, orderByKey: DatabaseColumn.optionId, isWhereKeyObjectType: true) { (success, data) in
            if success {
                for obj in data {
                    let qo = QuestionnaireOptionNew(questionOptionObject: obj)
                    self.dataQuestionnaire[questionIndex].questionOptionObjects.append(qo)
                }
                self.delegate?.questionnaire(isSuccess: true, questionOptionsData: self.dataQuestionnaire, msg: "Options fetched")
            } else {
                self.delegate?.questionnaire(isSuccess: false, questionOptionsData: [], msg: "Question options not found")
            }
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSuccess: false, questionOptionsData: [], msg: error)
        }
    }
    
    func getUserSavedOptions(questionObject: PFObject, questionIndex: Int) {
        ParseAPIManager.getAllData(from: DatabaseTable.userAnswer, whereKeyName: DatabaseColumn.questionId, whereKeyObject: questionObject, orderByKey: DatabaseColumn.optionId, isWhereKeyObjectType: true) { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                if data.count > 0 {
                    self.dataQuestionnaire[questionIndex].userSavedOptions = data[0]
                }
                self.delegate?.questionnaire(isSuccess: true, userSavedOptions: self.dataQuestionnaire, msg: "User saved options fetched")
            } else {
                self.delegate?.questionnaire(isSuccess: false, userSavedOptions: [], msg: "No saved options found")
            }
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSuccess: false, userSavedOptions: [], msg: error)
        }
    }
    
    func saveQuestionnaireOption(questionObject: PFObject, answersIds: [String]) {
        SVProgressHUD.show()
        ParseAPIManager.saveUserQuestionnaireOption(questionObject: questionObject, selectedOptionIds: answersIds) { (success) in
            SVProgressHUD.dismiss()
            self.delegate?.questionnaire(isSaved: true, msg: ValidationStrings.kQuestionnaireOptionSaved)
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSaved: false, msg: error)
        }
    }
    
    func updateUserOptions(userAnswerObject: PFObject) {
        SVProgressHUD.show()
        ParseAPIManager.updateObject(object: userAnswerObject) { (isSuccess) in
            SVProgressHUD.dismiss()
            self.delegate?.questionnaire(isUpdated: true, msg: "Option updated")
        } onFailure: { (error) in
            self.delegate?.questionnaire(isUpdated: false, msg: error)
        }
    }
    
    
}
