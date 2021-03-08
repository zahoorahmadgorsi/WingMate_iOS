//
//  EditProfilePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/01/2021.
//

import Foundation
import Parse
import SVProgressHUD

protocol EditProfileDelegate: class {
    func editProfile(isSuccess: Bool, msg: String, questions: [PFObject])
    func editProfile(isSuccess: Bool, msg: String, questionsList: ([PFObject], [PFObject]))
}

class EditProfilePresenter {
    
    weak var delegate: EditProfileDelegate?
    
    func attach(vc: EditProfileDelegate) {
        self.delegate = vc
    }
    
    func getQuestions() {
        SVProgressHUD.show()
        ParseAPIManager.getAllQuestions { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.editProfile(isSuccess: true, msg: "", questions: data)
            } else {
                self.delegate?.editProfile(isSuccess: false, msg: "No questions found", questions: [])
            }
        } onFailure: { (error) in
            print(error)
            self.delegate?.editProfile(isSuccess: false, msg: error, questions: [])
        }
    }
    
    func mapDataToModel(questions: [PFObject], userSavedOptions: [PFObject]) -> [UserProfileQuestion] {
        var data = [UserProfileQuestion]()
        //saving all questions to custom model
        for i in questions {
            data.append(UserProfileQuestion(questionObject: i))
        }
        //saving all user saved options to custom model
        for (i, qstn) in data.enumerated() {
            for (_, userSelectedOption) in userSavedOptions.enumerated() {
                //get question objectId
                let qstnObjectIdString = qstn.questionObject!.value(forKey: DBColumn.objectId) as? String ?? ""
                //get user selected option questionObjectId
                let userSelectedOptionQuestionObjectId = userSelectedOption.value(forKey: DBColumn.questionId) as? PFObject
               let userSelectedOptionQuestionObjectIdString = userSelectedOptionQuestionObjectId?.value(forKey: DBColumn.objectId) as? String ?? ""
                
                if qstnObjectIdString == userSelectedOptionQuestionObjectIdString {
                    data[i].userAnswerObject = userSelectedOption
                }
            }
        }
        return data
    }
    
    func filterQuestionLists(data: [UserProfileQuestion]?) -> ([PFObject], [PFObject]) {
        var optionalQuestions = [PFObject]()
        var mandatoryQuestions = [PFObject]()
        for i in data ?? [] {
            let questionType = i.questionObject?.value(forKey: DBColumn.questionType) as? String
            if questionType == QuestionType.mandatory.rawValue {
                if i.userAnswerObject != nil {
                    let optionsObjArray = i.userAnswerObject?.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
                    if optionsObjArray.count != 0 {
                        mandatoryQuestions.append(i.userAnswerObject!)
                    }
                }
            } else if questionType == QuestionType.optional.rawValue {
                if i.userAnswerObject != nil {
                    let optionsObjArray = i.userAnswerObject?.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
                    if optionsObjArray.count != 0 {
                        optionalQuestions.append(i.userAnswerObject!)
                    }
                }
            }
        }
        return (mandatoryQuestions, optionalQuestions)
    }
    
    func updateQuestionListsInUserTable(mandatoryQuestionList: [PFObject], optionalQuestionList: [PFObject]) {
        PFUser.current()?.setValue(mandatoryQuestionList, forKey: DBColumn.mandatoryQuestionAnswersList)
        PFUser.current()?.setValue(optionalQuestionList, forKey: DBColumn.optionalQuestionAnswersList)
        
        SVProgressHUD.show()
        ParseAPIManager.updateUserObject() { (success) in
            SVProgressHUD.dismiss()
            if success {
                APP_MANAGER.session = PFUser.current()
                self.delegate?.editProfile(isSuccess: true, msg: "Updated", questionsList: (mandatoryQuestionList, optionalQuestionList))
            } else {
                self.delegate?.editProfile(isSuccess: false, msg: "Update failed", questionsList: (mandatoryQuestionList, optionalQuestionList))
            }
        } onFailure: { (error) in
            self.delegate?.editProfile(isSuccess: false, msg: error, questionsList: (mandatoryQuestionList, optionalQuestionList))
        }
    }
    
}

struct UserProfileQuestion {
    var questionObject: PFObject?
    var userAnswerObject: PFObject?
    var searchedRecords: [PFObject]?

    init(){}

    init(questionObject: PFObject) {
        self.questionObject = questionObject
    }
    
    func getUserSelectedOptionsArray() -> [PFObject] {
        return userAnswerObject?.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
    }
    
    func getUserSelectedOptionsArrayString() -> [String] {
        return userAnswerObject?.value(forKey: DBColumn.selectedOptionIds) as? [String] ?? []
    }
    
}
