//
//  SearchVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/02/2021.
//

import UIKit
import Parse

class SearchVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var tableViewFilters: UITableView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    var presenter = SearchPresenter()
    var dataQuestions: [UserProfileQuestion]?
    var searchedUsers = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.setInitialLayout()
        self.tableViewFilters.estimatedRowHeight = 40
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presenter.getQuestions(questionType: .mandatory)
    }
    
    //MARK: - Helping Methods
    func setInitialLayout() {
        //set profile image
    }
    
    func registerTableViewCells() {
        self.tableViewFilters.register(UINib(nibName: EditProfileUserQuestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: EditProfileUserQuestionTableViewCell.className)
    }
    
    //MARK: - Button Actions
    @IBAction func searchButtonPressed(_ sender: Any) {
        var searchArray = [PFObject]()
        var totalQuestionsMarkedByUser = 0
        for i in self.dataQuestions ?? [] {
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
                if uniqueUsersData.map({$0.objectId}).contains(userObjToMatch?.objectId!) == false {
                    uniqueUsersData.append(userObjToMatch!)
                }
            }
        }
        print("Total users found: \(uniqueUsersData.count)")
        self.searchedUsers = uniqueUsersData
    }
    
    @IBAction func resetFilterButtonPressed(_ sender: Any) {
        
    }
    
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileUserQuestionTableViewCell.className, for: indexPath) as! EditProfileUserQuestionTableViewCell
        cell.data = self.dataQuestions?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = OptionSelectionVC(userProfileData: self.dataQuestions![indexPath.row], isSearchFlow: true)
        vc.userAnswerUpdated = { [weak self] updatedUserAnswer in
            self?.dataQuestions![indexPath.row].userAnswerObject = updatedUserAnswer
            self?.tableViewFilters.reloadData()
            self?.presenter.searchUsers(data: (self?.dataQuestions![indexPath.row])!, index: indexPath.row)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataQuestions?.count ?? 0
    }
}

extension SearchVC: SearchDelegate {
    func search(isSuccess: Bool, msg: String, questions: [PFObject]) {
        self.dataQuestions = self.presenter.mapQuestionsToModel(questions: questions)
        self.tableViewFilters.reloadData()
    }
    
    func search(isSuccess: Bool, msg: String, searchResults: [PFObject], index: Int) {
        if isSuccess {
            print(searchResults)
            self.dataQuestions?[index].searchedRecords = searchResults
        } else {
            self.showToast(message: msg)
        }
    }
}

struct UserTest:Hashable {
    let id:Int
}
