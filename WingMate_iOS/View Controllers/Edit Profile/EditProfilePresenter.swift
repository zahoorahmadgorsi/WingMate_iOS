//
//  EditProfilePresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/01/2021.
//

import Foundation
import Parse
import SVProgressHUD

protocol EditProfileDelegate {
    func editProfile(isSuccess: Bool, msg: String, questions: [PFObject])
}

class EditProfilePresenter {
    
    var delegate: EditProfileDelegate?
    
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
    
}

struct UserProfileQuestion {
    var questionObject: PFObject?
    var userAnswerObject: PFObject?

    init(){}

    init(questionObject: PFObject) {
        self.questionObject = questionObject
    }
}
