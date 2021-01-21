//
//  OptionSelectionPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 21/01/2021.
//


protocol OptionSelectionDelegate {
    func optionSelection()
}

import Foundation
import SVProgressHUD
import Parse

class OptionSelectionPresenter {
    
    var delegate: OptionSelectionDelegate?
    
    func attach(vc: OptionSelectionDelegate) {
        self.delegate = vc
    }
    
    func isSelectedOption() -> Bool {
        return false
    }
    
    func saveUserOptions(questionObject: PFObject, answersIds: [String], answersObjects: [PFObject]) {
        SVProgressHUD.show()
        ParseAPIManager.saveUserQuestionOptions(questionObject: questionObject, selectedOptionIds: answersIds, savedOptionsObjects: answersObjects) { (success) in
            SVProgressHUD.dismiss()
//            self.delegate?.questionnaire(isSaved: true, msg: ValidationStrings.kQuestionnaireOptionSaved)
        } onFailure: { (error) in
//            self.delegate?.questionnaire(isSaved: false, msg: error)
        }
    }
    
    func updateUserOptions(userAnswerObject: PFObject) {
        SVProgressHUD.show()
        ParseAPIManager.updateUserQuestionOptions(object: userAnswerObject) { (isSuccess) in
            SVProgressHUD.dismiss()
//            self.delegate?.questionnaire(isUpdated: true, msg: "Option updated")
        } onFailure: { (error) in
//            self.delegate?.questionnaire(isUpdated: false, msg: error)
        }
    }
    
}
