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
    
    var presenter = DashboardPresenter()
    var dataUsers = [PFUser]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.setInitialLayout()
        self.navigationController?.isNavigationBarHidden = true
        self.registerTableViewCells()
        self.presenter.getUsers()
        self.addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setInitialLayout()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    //MARK: - Helping Methods
    func registerTableViewCells() {
        self.collectionViewUsers.register(UINib(nibName: SearchUserCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: SearchUserCollectionViewCell.className)
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.collectionViewUsers.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.endRefreshing()
        self.presenter.getUsers()
    }
    
    func setInitialLayout() {
        //set profile image
        let profileImage = APP_MANAGER.session?.value(forKey: DBColumn.profilePic) as? String ?? ""
        if profileImage == "" {
            self.imageViewProfile.image = UIImage(named: "default_placeholder")
        } else {
            self.setImageWithUrl(imageUrl: profileImage, imageView: self.imageViewProfile, placeholderImage: UIImage(named: "default_placeholder"))
        }
    }
    
    //MARK: - Button Actions
    @IBAction func myFansButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func messagesButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func compatibleButtonPressed(_ sender: Any) {
        
    }
    
}

//MARK: - Collection View Delegates
extension DashboardVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchUserCollectionViewCell.className, for: indexPath) as! SearchUserCollectionViewCell
        cell.data = self.dataUsers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ProfileVC(user: self.dataUsers[indexPath.item])
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewUsers.frame.width/2, height: self.collectionViewUsers.frame.width/2)
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
            self.dataUsers = users
            self.collectionViewUsers.reloadData()
        } else {
            self.showToast(message: msg)
        }
    }
}
