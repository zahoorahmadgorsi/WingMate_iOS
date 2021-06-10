//
//  DashboardVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/11/2020.
//

import UIKit
import SVProgressHUD
import Parse

class DashboardVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var collectionViewUsers: UICollectionView!
    @IBOutlet weak var labelQuote: UILabel!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var viewHeader: UIView!
    
    var presenter = DashboardPresenter()
    var dataUsers = [DashboardData]()
    var refreshControl = UIRefreshControl()
    var myUserOptions = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.saveInstallationToken()
        self.setLayout()
        self.presenter.attach(vc: self)
        self.navigationController?.isNavigationBarHidden = true
        self.registerTableViewCells()
        self.presenter.getUsers()
        self.addPullToRefresh()
//        self.setViewControllers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        
        DispatchQueue.global(qos: .background).async {
            self.myUserOptions = self.getMyUserOptions()
        }
        
        if self.isTimeExpiredToRecallAPIs() {
            
            let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
            let isMandatoryQuestionsFilled = PFUser.current()?.value(forKey: DBColumn.isMandatoryQuestionnairesFilled) as? Bool ?? false
            
            if isPaidUser && !isMandatoryQuestionsFilled {
                let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.checkAccountStatus()
            }
        } else {
            print("not expired")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: - Helping Methods
    func setLayout() {
        self.viewHeader.clipsToBounds = true
        self.viewHeader.layer.cornerRadius = 30
        self.viewHeader.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    func setViewControllers() {
        let vc1 = DashboardVC() // UINavigationController(rootViewController: DashboardVC())
        let vc2 = SettingsVC() //UINavigationController(rootViewController: SettingsVC())
//        self.tabBarController?.setViewControllers([vc1, vc2], animated: true)
        
        self.tabBarController?.setViewControllers([vc1, vc2], animated: true)
        
    }
    
    func registerTableViewCells() {
        self.collectionViewUsers.register(UINib(nibName: SearchUserCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: SearchUserCollectionViewCell.className)
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.collectionViewUsers.refreshControl = refreshControl
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.endRefreshing()
        self.presenter.getUsers()
    }
    
    func saveInstallationToken() {
        APP_DELEGATE.createInstallationOnParse(userId: PFUser.current()?.value(forKey: DBColumn.objectId) as? String ?? "")
    }
    
    //MARK: - Button Actions
    @IBAction func profilePictureButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile)
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func myFansButtonPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func messagesButtonPressed(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    
    @IBAction func compatibleButtonPressed(_ sender: Any) {
        self.dataUsers = self.dataUsers.sorted { (d1, d2) -> Bool in
            return d1.percentageMatch > d2.percentageMatch
        }
        self.collectionViewUsers.reloadData()
    }
    
}

//MARK: - Collection View Delegates
extension DashboardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchUserCollectionViewCell.className, for: indexPath) as! SearchUserCollectionViewCell
        cell.myUserOptions = self.myUserOptions
        cell.dataUsers = self.dataUsers[indexPath.row]
        cell.setPercentageMatchValue = { [weak self] percentage in
            self?.dataUsers[indexPath.item].percentageMatch = percentage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProfileVC(user: self.dataUsers[indexPath.item].user!)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewUsers.frame.width/2, height: (self.collectionViewUsers.frame.width/2)+40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.numberOfItems(inSection: section) == 1 {
            let cellWidth = self.collectionViewUsers.frame.width/2
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - cellWidth)
        }
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension DashboardVC: DashboardDelegate {
    func dashboard(isSuccess: Bool, msg: String, users: [PFUser]) {
        if isSuccess {
            self.dataUsers.removeAll()
            for i in users {
                self.dataUsers.append(DashboardData(user: i))
            }
            self.collectionViewUsers.reloadData()
        } else {
            self.showToast(message: msg)
        }
    }
}


class DashboardData {
    var user: PFUser?
    var percentageMatch: Int
    
    init(user: PFUser) {
        self.user = user
        self.percentageMatch = 0
    }
}
