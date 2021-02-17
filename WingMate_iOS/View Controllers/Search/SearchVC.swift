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
    @IBOutlet weak var collectionViewSearchRecords: UICollectionView!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var viewNoResults: UIView!
    @IBOutlet weak var buttonSearch: UIButton!
    var presenter = SearchPresenter()
    var dataQuestions: [UserProfileQuestion]?
    var searchedUsers = [PFUser]()
    var isFiltersMode = true
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.setInitialLayout()
        self.tableViewFilters.estimatedRowHeight = 40
        self.navigationController?.isNavigationBarHidden = true
        
        self.showFiltersTableView()
        self.resetAllFilters()
        self.presenter.getQuestions(questionType: .mandatory)
        self.addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let profileImage = APP_MANAGER.session?.value(forKey: DBColumn.profilePic) as? String ?? ""
        if profileImage == "" {
            self.imageViewProfile.image = UIImage(named: "default_placeholder")
        } else {
            self.setImageWithUrl(imageUrl: profileImage, imageView: self.imageViewProfile, placeholderImage: UIImage(named: "default_placeholder"))
        }
    }
    
    //MARK: - Helping Methods
    func setInitialLayout() {
        //set profile image
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tableViewFilters.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.endRefreshing()
        self.showFiltersTableView()
        self.resetAllFilters()
        self.presenter.getQuestions(questionType: .mandatory)
    }
    
    func showFiltersTableView() {
        self.tableViewFilters.isHidden = false
        self.viewNoResults.isHidden = true
        self.collectionViewSearchRecords.isHidden = true
    }
    
    func showNoRecordsView() {
        self.viewNoResults.isHidden = false
        self.tableViewFilters.isHidden = true
        self.collectionViewSearchRecords.isHidden = true
    }
    
    func showSearchedRecordsTableView() {
        self.collectionViewSearchRecords.reloadData()
        self.viewNoResults.isHidden = true
        self.tableViewFilters.isHidden = true
        self.collectionViewSearchRecords.isHidden = false
    }
    
    func resetAllFilters() {
        self.isFiltersMode = true
        self.buttonSearch.setTitle("Search", for: .normal)
        if self.dataQuestions != nil {
            self.presenter.resetFilters(dataQuestions: &self.dataQuestions!)
        }
        self.tableViewFilters.reloadData()
    }
    
    func registerTableViewCells() {
        self.tableViewFilters.register(UINib(nibName: EditProfileUserQuestionTableViewCell.className, bundle: nil), forCellReuseIdentifier: EditProfileUserQuestionTableViewCell.className)
        self.collectionViewSearchRecords.register(UINib(nibName: SearchUserCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: SearchUserCollectionViewCell.className)
    }
    
    //MARK: - Button Actions
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.isFiltersMode = !self.isFiltersMode
        if self.isFiltersMode {
            self.buttonSearch.setTitle("Search", for: .normal)
            self.showFiltersTableView()
        } else {
            self.buttonSearch.setTitle("Search Again", for: .normal)
            self.searchedUsers = self.presenter.getCommonUsersAppearedInAllQueries(dataQuestions: self.dataQuestions)
            if self.searchedUsers.count > 0 {
                self.showSearchedRecordsTableView()
            } else {
                self.showNoRecordsView()
            }
        }
    }
    
    @IBAction func resetFilterButtonPressed(_ sender: Any) {
        self.showFiltersTableView()
        self.resetAllFilters()
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

//MARK: - Collection View Delegates
extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchUserCollectionViewCell.className, for: indexPath) as! SearchUserCollectionViewCell
        cell.data = self.searchedUsers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProfileVC(user: self.searchedUsers[indexPath.item])
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.searchedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewSearchRecords.frame.width/2, height: self.collectionViewSearchRecords.frame.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            let cellWidth = self.collectionViewSearchRecords.frame.width/2
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - cellWidth)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
