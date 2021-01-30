//
//  OptionSelectionPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 21/01/2021.
//


protocol OptionSelectionDelegate {
    func optionSelection(isSuccess: Bool, msg: String, updatedUserAnswerObject: PFObject)
}

import Foundation
import SVProgressHUD
import Parse

class OptionSelectionPresenter {
    
    var delegate: OptionSelectionDelegate?
    
    func attach(vc: OptionSelectionDelegate) {
        self.delegate = vc
    }
    
    func isSelectedOption(option: PFObject, userAnswerObject: PFObject?) -> Bool {
        if let obj = userAnswerObject {
            let userSelectedOptions = obj.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
            for i in userSelectedOptions {
                let optionObjId = option.value(forKey: DBColumn.objectId) as? String ?? ""
                let userOptionObjId = i.value(forKey: DBColumn.objectId) as? String ?? ""
                if optionObjId == userOptionObjId {
                    return true
                }
            }
        }
        return false
    }
    
    func getIndexOfSelectedOptionalQuestion(userOptions: [PFObject], questionOption: PFObject) -> Int {
        var deleteIndex = -1
        for (i,item) in userOptions.enumerated() {
            let optionId = questionOption.value(forKey: DBColumn.objectId) as? String ?? ""
            let userOptionObjId = item.value(forKey: DBColumn.objectId) as? String ?? ""
            if optionId == userOptionObjId {
                deleteIndex = i
            }
        }
        return deleteIndex
    }
    
    func isMandatoryQuestion(data: UserProfileQuestion) -> Bool {
        let qstnType = data.questionObject?.value(forKey: DBColumn.questionType) as? String ?? ""
        return qstnType == QuestionType.mandatory.rawValue ? true : false
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
            self.delegate?.optionSelection(isSuccess: true, msg: "Updated Successfully", updatedUserAnswerObject: userAnswerObject)
        } onFailure: { (error) in
            self.delegate?.optionSelection(isSuccess: false, msg: "", updatedUserAnswerObject: PFObject())
        }
    }
    
}
