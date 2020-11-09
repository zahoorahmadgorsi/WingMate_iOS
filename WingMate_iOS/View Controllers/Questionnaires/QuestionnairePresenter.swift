//
//  QuestionnairePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 08/11/2020.
//

import Foundation

protocol QuestionnaireDelegate {
    func questionnaire(isSuccess: Bool, questionData: [Question], msg: String)
    func questionnaire(isSuccess: Bool, questionOptionsData: [Question], msg: String)
}

class QuestionnairePresenter {
    
    var delegate: QuestionnaireDelegate?
    var dataQuestionnaire = [Question]()
    
    func attach(vc: QuestionnaireDelegate) {
        self.delegate = vc
    }
    
    func getAllQuestions(questionType: QuestionType) {
        ParseAPIManager.getAllData(from: "Question", whereKeyName: "questionType", whereKeyValue: questionType.rawValue, orderByKey: "displayOrder") { (success, data) in
            print("data")
            if success {
                for obj in data {
                    let title = obj.value(forKey: "title") as? String ?? ""
                    let questionObjectId = obj.value(forKey: "objectId") as? String ?? ""
                    self.dataQuestionnaire.append(Question(title: title, questionObjectId: questionObjectId, questionOptions: []))
                }
                self.delegate?.questionnaire(isSuccess: true, questionData: self.dataQuestionnaire, msg: "Questions fetched")
            } else {
                self.delegate?.questionnaire(isSuccess: false, questionData: [], msg: "No questions found")
            }
        } onFailure: { (error) in
            self.delegate?.questionnaire(isSuccess: false, questionData: [], msg: error)
        }
    }
    
    func getAllOptionsOfQuestion(questionObjectId: String, questionIndex: Int) {
//        ParseAPIManager.getAllData(from: "QuestionOption", whereKeyName: "questionId", whereKeyValue: questionObjectId, orderByKey: "optionId") { (success, data) in
//            print("data")
//            if success {
//                for obj in data {
//                    let optionObjectId = obj.value(forKey: "objectId") as? String ?? ""
//                    let questionObjectId = obj.value(forKey: "questionId") as? String ?? ""
//                    let title = obj.value(forKey: "title") as? String ?? ""
//                    let countryFlagImage = obj.value(forKey: "countryFlagImage") as? String ?? ""
//                    self.dataQuestionnaire[questionIndex].questionOptions.append(QuestionOption(title: title, questionObjectId: questionObjectId, optionObjectId: optionObjectId, countryFlag: countryFlagImage))
//                }
//                self.delegate?.questionnaire(isSuccess: true, questionOptionsData: self.dataQuestionnaire, msg: "Options fetched")
//            } else {
//                self.delegate?.questionnaire(isSuccess: false, questionData: [], msg: "No questions found")
//            }
//        } onFailure: { (error) in
//            self.delegate?.questionnaire(isSuccess: false, questionData: [], msg: error)
//        }
        
        ParseAPIManager.getAllDataWithObject(questionId: questionObjectId, onSuccess: { (success, data) in
            print(data)
        }, onFailure: { (error) in
            print(error)
        })
        
    }
    
}
