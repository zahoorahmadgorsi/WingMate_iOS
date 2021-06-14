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
    @IBOutlet weak var viewNoResults: UIView!
    let presenter = FansPresenter()
    var selectedFanType: FanType = .like
    var dataUsers = [PFObject]()
    var fromUsers = [PFObject]()
    var dataLikeUsers = [PFObject]()
    var dataCrushUsers = [PFObject]()
    var dataMaybeUsers = [PFObject]()
    var refreshControl = UIRefreshControl()
    var myUserOptions = [PFObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.presenter.getUsers()
        self.addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        
        DispatchQueue.global(qos: .background).async {
            self.myUserOptions = self.getMyUserOptions()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    //MARK: - Helping Methods
    func registerTableViewCells() {
        self.collectionViewUsers.register(UINib(nibName: SearchUserCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: SearchUserCollectionViewCell.className)
    }
    
    func addPullToRefresh() {
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.collectionViewUsers.refreshControl = refreshControl
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.presenter.getUsers(shouldShowLoader: false)
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
//        self.previewImage(imageView: self.imageViewProfile)
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        vc.refreshFansList = {
            self.presenter.getUsers()
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
        cell.myUserOptions = self.myUserOptions
        cell.selectedFanType = self.selectedFanType
        cell.fromUsers = self.fromUsers
        cell.dataFans = self.dataUsers[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let usr = (self.dataUsers[indexPath.item].value(forKey: DBColumn.fromUser) as? PFUser)!
        let vc = ProfileVC(user: usr)
        vc.hidesBottomBarWhenPushed = true
        vc.refreshFansList = {
            self.presenter.getUsers()
        }
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

extension FansVC: FansDelegate {
    func fans(isSuccess: Bool, msg: String, users: [PFObject]) {
        self.refreshControl.endRefreshing()
        if isSuccess {
            self.viewNoResults.isHidden = true
            self.dataLikeUsers.removeAll()
            self.dataMaybeUsers.removeAll()
            self.dataCrushUsers.removeAll()
            self.dataUsers.removeAll()
            self.fromUsers.removeAll()
            
            for i in users {
                let toUser = i.value(forKey: DBColumn.toUser) as? PFUser
                let fromUser = i.value(forKey: DBColumn.fromUser) as? PFUser
                let toUserObjId = toUser?.value(forKey: DBColumn.objectId) as? String ?? ""
                let fromUserObjId = fromUser?.value(forKey: DBColumn.objectId) as? String ?? ""
                let currentUserObjId = PFUser.current()?.value(forKey: DBColumn.objectId) as? String ?? ""
                let fromIsActiveUser = fromUser?.value(forKey: DBColumn.accountStatus) as? Int ?? 0
                if (toUserObjId == currentUserObjId) {
                    if fromIsActiveUser == UserAccountStatus.accepted.rawValue {
                        self.dataUsers.append(i)
                    }
                }
                if (fromUserObjId == currentUserObjId) {
                    self.fromUsers.append(i)
                }
            }
            
            for i in self.dataUsers {
                let fanType = i.value(forKey: DBColumn.fanType) as? String
                
                switch fanType {
                case FanType.like.rawValue:
                    self.dataLikeUsers.append(i)
                case FanType.maybe.rawValue:
                    self.dataMaybeUsers.append(i)
                case FanType.crush.rawValue:
                    self.dataCrushUsers.append(i)
                default:
                    break
                }
            }
            switch self.selectedFanType {
            case .like:
                self.dataUsers = self.dataLikeUsers
                if self.dataUsers.count == 0 {
                    self.viewNoResults.isHidden = false
                }
                break
            case .maybe:
                self.dataUsers = self.dataMaybeUsers
                if self.dataUsers.count == 0 {
                    self.viewNoResults.isHidden = false
                }
                break
            case .crush:
                self.dataUsers = self.dataCrushUsers
                if self.dataUsers.count == 0 {
                    self.viewNoResults.isHidden = false
                }
                break
            }
            self.labelMyLikes.text = "\(self.dataLikeUsers.count)"
            self.labelMaybe.text = "\(self.dataMaybeUsers.count)"
            self.labelCrush.text = "\(self.dataCrushUsers.count)"
            self.collectionViewUsers.reloadData()
            
        
        } else {
            self.showToast(message: msg)
        }
    }
}
