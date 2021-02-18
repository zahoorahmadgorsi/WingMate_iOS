//
//  SearchPresenter.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/02/2021.
//

import Foundation
import Parse
import SVProgressHUD

protocol SearchDelegate {
    func search(isSuccess: Bool, msg: String, questions: [PFObject])
    func search(isSuccess: Bool, msg: String, searchResults: [PFObject], index: Int)
}

class SearchPresenter {
    
    var delegate: SearchDelegate?
    
    func attach(vc: SearchDelegate) {
        self.delegate = vc
    }
    
    func getQuestions(questionType: QuestionType) {
        SVProgressHUD.show()
        ParseAPIManager.getQuestions(questionType: questionType.rawValue)
        { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.search(isSuccess: true, msg: "", questions: data)
            } else {
                self.delegate?.search(isSuccess: false, msg: "No questions found", questions: [])
            }
        } onFailure: { (error) in
            print(error)
            SVProgressHUD.dismiss()
            self.delegate?.search(isSuccess: false, msg: error, questions: [])
        }
    }
    
    func mapQuestionsToModel(questions: [PFObject]) -> [UserProfileQuestion] {
        var data = [UserProfileQuestion]()
        for i in questions {
            data.append(UserProfileQuestion(questionObject: i))
        }
        return data
    }
    
    func searchUsers(data: UserProfileQuestion, index: Int) {
        SVProgressHUD.show()
        ParseAPIManager.searchUsers(data: data) { (success, data) in
            SVProgressHUD.dismiss()
            if success {
                self.delegate?.search(isSuccess: true, msg: "", searchResults: data, index: index)
            } else {
                self.delegate?.search(isSuccess: false, msg: "No questions found", searchResults: [], index: index)
            }
        } onFailure: { (error) in
            SVProgressHUD.dismiss()
            self.delegate?.search(isSuccess: false, msg: error, searchResults: [], index: index)
        }
    }
    
    func getCommonUsersAppearedInAllQueries(dataQuestions: [UserProfileQuestion]?) -> [PFUser] {
        var searchArray = [PFObject]()
        var totalQuestionsMarkedByUser = 0
        for i in dataQuestions ?? [] {
            if i.userAnswerObject != nil {
                totalQuestionsMarkedByUser = totalQuestionsMarkedByUser + 1
                for j in i.searchedRecords ?? [] {
                    searchArray.append(j)
                }
            }
        }
        
        var uniqueUsersData = [PFUser]()
        for i in searchArray {
            var totalCount = 0
            let userObjToMatch = i.value(forKey: DBColumn.userId) as? PFUser
            for j in searchArray {
                let iteratedUserObj = j.value(forKey: DBColumn.userId) as? PFUser
                if (userObjToMatch?.objectId ?? "") == (iteratedUserObj?.objectId ?? "") {
                    totalCount = totalCount + 1
                }
            }
            if totalCount == totalQuestionsMarkedByUser {
                if (uniqueUsersData.map({$0.objectId}).contains(userObjToMatch?.objectId!) == false) {
                    if userObjToMatch?.objectId != APP_MANAGER.session?.objectId {
                        uniqueUsersData.append(userObjToMatch!)
                    }
                }
            }
        }
        print("Total users found: \(uniqueUsersData.count)")
        return uniqueUsersData
    }
    
    func resetFilters(dataQuestions: inout [UserProfileQuestion]) {
        for i in 0..<dataQuestions.count {
            dataQuestions[i].searchedRecords = nil
            dataQuestions[i].userAnswerObject = nil
        }
    }
}
