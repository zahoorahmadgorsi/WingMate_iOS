//
//  FansVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 16/02/2021.
//

import UIKit
import Parse

class FansVC: BaseViewController {
    
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var viewBgCrush: UIView!
    @IBOutlet weak var viewBgMaybe: UIView!
    @IBOutlet weak var viewBgMyLikes: UIView!
    @IBOutlet weak var labelCrush: UILabel!
    @IBOutlet weak var labelMaybe: UILabel!
    @IBOutlet weak var labelMyLikes: UILabel!
    @IBOutlet weak var labelStaticCrush: UILabel!
    @IBOutlet weak var labelStaticMaybe: UILabel!
    @IBOutlet weak var labelStaticMyLikes: UILabel!
    @IBOutlet weak var collectionViewUsers: UICollectionView!
    let presenter = FansPresenter()
    var selectedFanType: FanType = .like
    var dataUsers = [PFUser]()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.presenter.getUsers()
        self.addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
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
    func updateUI() {
        self.viewBgCrush.backgroundColor = UIColor.clear
        self.viewBgMyLikes.backgroundColor = UIColor.clear
        self.viewBgMaybe.backgroundColor = UIColor.clear
        self.labelStaticCrush.textColor = UIColor.appThemePurpleColor
        self.labelStaticMaybe.textColor = UIColor.appThemePurpleColor
        self.labelStaticMyLikes.textColor = UIColor.appThemePurpleColor
        switch self.selectedFanType {
        case .like:
            self.labelStaticMyLikes.textColor = UIColor.white
            self.viewBgMyLikes.backgroundColor = UIColor.appThemePurpleColor
            break
        case .crush:
            self.labelStaticCrush.textColor = UIColor.white
            self.viewBgCrush.backgroundColor = UIColor.appThemePurpleColor
            break
        case .maybe:
            self.labelStaticMaybe.textColor = UIColor.white
            self.viewBgMaybe.backgroundColor = UIColor.appThemePurpleColor
            break
        }
        self.presenter.getUsers()
    }
    
    //MARK: - Button Actions
    @IBAction func profilePictureButtonPressed(_ sender: Any) {
        self.previewImage(imageView: self.imageViewProfile)
    }
    
    @IBAction func myLikesButtonPressed(_ sender: Any) {
        self.selectedFanType = .like
        self.updateUI()
    }
    
    @IBAction func crushButtonPressed(_ sender: Any) {
        self.selectedFanType = .crush
        self.updateUI()
    }
    
    @IBAction func maybeButtonPressed(_ sender: Any) {
        self.selectedFanType = .maybe
        self.updateUI()
    }
    
}

//MARK: - Collection View Delegates
extension FansVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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

extension FansVC: FansDelegate {
    func fans(isSuccess: Bool, msg: String, users: [PFUser]) {
        if isSuccess {
            self.dataUsers = users
            self.collectionViewUsers.reloadData()
        } else {
            self.showToast(message: msg)
        }
    }
}
