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
    @IBOutlet weak var viewFloatingBottom: UIView!
    @IBOutlet weak var labelFloating: UILabel!
    
    var presenter = DashboardPresenter()
    var dataUsers = [DashboardData]()
    var refreshControl = UIRefreshControl()
    var myUserOptions = [PFObject]()
    var isTrialExpired = false
    var isLaunchCampaign = false
    var quotes = [String]()
    var timer = Timer()
    var timerCounter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewFloatingBottom.isHidden = true
        
        self.saveInstallationToken()
        self.processUserState(isBottomViewTapped: false)
        self.setLayout()
        self.presenter.attach(vc: self)
        self.navigationController?.isNavigationBarHidden = true
        self.registerTableViewCells()
        self.presenter.getUsers()
        self.addPullToRefresh()
        self.launchCampaign()
        NotificationCenter.default.addObserver(self, selector: #selector(self.resetBottomFloatingViewText(notification:)), name: Notification.Name("resetBottomFloatingViewText"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshUserObject(notification:)), name: Notification.Name("refreshUserObject"), object: nil)
         getAllQuotes()
        
        //        self.setViewControllers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

    
    @objc func refreshUserObject(notification: Notification) {
        self.processUserState(isBottomViewTapped: false)
    }
    
    @objc func resetBottomFloatingViewText(notification: Notification) {
        let status = PFUser.current()?.value(forKey: DBColumn.accountStatus) as? Int ?? 0
        let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
        let isPhotosSubmitted = PFUser.current()?.value(forKey: DBColumn.isPhotosSubmitted) as? Bool ?? false
        let isVideoSubmitted = PFUser.current()?.value(forKey: DBColumn.isVideoSubmitted) as? Bool ?? false
        
        if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
            self.labelFloating.text = ValidationStrings.photosVideoRequiredToUpload
        } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
            self.labelFloating.text = ValidationStrings.profileUnderScreening
        } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
            self.isTrialPeriodExpired { (isExpired, daysLeft) in
                if !isExpired {
                    self.labelFloating.text = "\(daysLeft) \(ValidationStrings.daysLeftForTrialExpiry)"
                } else {
                    self.isTrialExpired = true
                }
            }
        }
        
        if isPaidUser {
            self.viewFloatingBottom.isHidden = true
        }
    }

    
    func processUserState(isBottomViewTapped: Bool) {
        self.getAccountStatus(completion: { (status) in
            
            if status == UserAccountStatus.rejected.rawValue {
                self.showAlertOK(APP_NAME, message: ValidationStrings.kAccountRejected) { action in
                    self.logoutUser()
                }
                return
            }
            
            let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
            let isPhotosSubmitted = PFUser.current()?.value(forKey: DBColumn.isPhotosSubmitted) as? Bool ?? false
            let isVideoSubmitted = PFUser.current()?.value(forKey: DBColumn.isVideoSubmitted) as? Bool ?? false
            let isMandatoryQuestionsFilled = PFUser.current()?.value(forKey: DBColumn.isMandatoryQuestionnairesFilled) as? Bool ?? false
            
            self.isTrialPeriodExpired { (isExpired, daysLeft) in
                SVProgressHUD.dismiss()
                if isExpired {
                    self.isTrialExpired = true
                    self.viewFloatingBottom.isHidden = true
                    if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToUploadPhotosVideoTrialExpired) { action in
                            let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: isExpired)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToWaitTrialExpired) { action in
                            self.navigationController?.pushViewController(WaitingVC(), animated: true)
                        }
                    } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                        if self.isLaunchCampaign == false {
                        //SHOW PAYMENT SCREEN HERE
                        }else {
                            let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else if isPaidUser && !isMandatoryQuestionsFilled && status == UserAccountStatus.accepted.rawValue{
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToFillMandatoryQuestionnaires) { action in
                            let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                } else {
                    if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToUploadPhotosVideo) { action in
                            self.labelFloating.text = ValidationStrings.photosVideoRequiredToUpload
                            let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: isExpired)
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
                        self.labelFloating.text = ValidationStrings.profileUnderScreening
                    } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                        self.labelFloating.text = "\(daysLeft) \(ValidationStrings.daysLeftForTrialExpiry)"
                        if isBottomViewTapped {
                            if self.isLaunchCampaign == false {
                            let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                            }else {
                                let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }                        }
                    } else if isPaidUser && !isMandatoryQuestionsFilled && status == UserAccountStatus.accepted.rawValue {
                        if !isBottomViewTapped {
                            self.showAlertOK(APP_NAME, message: ValidationStrings.needToFillMandatoryQuestionnaires) { action in
                                let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
                                vc.hidesBottomBarWhenPushed = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    }
                    self.viewFloatingBottom.isHidden = false
                    
                    if isPaidUser && status == UserAccountStatus.accepted.rawValue {
                        self.viewFloatingBottom.isHidden = true
                   }
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.setProfileImage(imageViewProfile: self.imageViewProfile)
        
        DispatchQueue.global(qos: .background).async {
            self.myUserOptions = self.getMyUserOptions()
        }
        self.resetBottomFloatingViewText(notification: Notification(name: Notification.Name(rawValue: "")))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.tabBarController?.tabBar.isHidden = false
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
        self.presenter.getUsers(shouldShowLoader: false)
    }
    
    func saveInstallationToken() {
        APP_DELEGATE.createInstallationOnParse(userId: PFUser.current()?.value(forKey: DBColumn.objectId) as? String ?? "")
    }
    
    //MARK: - Button Actions
    @IBAction func profilePictureButtonPressed(_ sender: Any) {
        //        self.previewImage(imageView: self.imageViewProfile)
        let vc = ProfileVC(user: APP_MANAGER.session!)
        vc.hidesBottomBarWhenPushed = true
        vc.isTrialExpired = self.isTrialExpired
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
    
    @IBAction func redViewButtonPressed(_ sender: Any) {
        SVProgressHUD.show()
        self.processUserState(isBottomViewTapped: true)
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
        print("ENDED")
        self.refreshControl.endRefreshing()
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
    func launchCampaign(){
        let parseObject = PFQuery(className: "LaunchCampaign")
        parseObject.getObjectInBackground(withId: "NzU48aDCP9") { (object, error) in
            if error == nil {
                if let obj = object {
                    print(obj["launchCampaign"] as! Bool)
                    self.isLaunchCampaign = obj["launchCampaign"] as! Bool
                    let val = obj["launchCampaign"] as! Bool
                    UserDefaults.standard.setValue(val, forKey: UserDefaultKeys.launchCampaign)
                    
                }
            }
        }
    }
    func getAllQuotes() {
     
        let parseObject = PFQuery(className:"Quotes")
        parseObject.selectKeys(["quote"])
        parseObject.findObjectsInBackground { (object, error) in
            if error == nil {
                for obj in object! {
                    let quote = obj["quote"] as! String
                    self.quotes.append(quote)
                }
            }
            let randomQuote = self.quotes.randomItem()
            let slit = randomQuote?.components(separatedBy: ".")
            self.labelQuote.text = slit![0]
            self.labelAuthor.text = slit![1]
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
        }
     
    }
    @objc func timerAction() {
        self.timerCounter += 1
        
        if self.timerCounter == 900 {
            let randomQuote = self.quotes.randomItem()
            let slit = randomQuote?.components(separatedBy: ".")
            self.labelQuote.text = slit![0]
            self.labelAuthor.text = slit![1]
        }else if self.timerCounter == 1800 {
            timer.invalidate()
            self.timerCounter = 0
            let randomQuote = self.quotes.randomItem()
            let slit = randomQuote?.components(separatedBy: ".")
            self.labelQuote.text = slit![0]
            self.labelAuthor.text = slit![1]
        }
        print("Task is Running...")
    }
}
extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
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
