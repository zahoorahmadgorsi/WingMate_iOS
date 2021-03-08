//
//  ProfileVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/01/2021.
//

import UIKit
import UICircularProgressRing
import Parse
import AVKit
import SVProgressHUD

class ProfileVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var imageViewProfile1: UIImageView!
    @IBOutlet weak var imageViewProfile2: UIImageView!
    @IBOutlet weak var imageViewProfile3: UIImageView!
    @IBOutlet weak var imageViewVideo: UIImageView!
    @IBOutlet weak var labelAboutMe: UILabel!
    @IBOutlet weak var cstHeightOthersProfileStackView: NSLayoutConstraint!
    @IBOutlet weak var stackViewMyProfileButtons: UIStackView!
    @IBOutlet weak var viewRefresh: UIView!
    @IBOutlet weak var stackViewOthersProfileButtons: UIStackView!
    @IBOutlet weak var tableViewUserQuestions: UITableView!
    @IBOutlet weak var cstHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var progressView: UICircularProgressRing!
    @IBOutlet weak var labelMatchPercentage: UILabel!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var cstTopImageView: NSLayoutConstraint!
    @IBOutlet weak var viewBlocker: UIView!
    @IBOutlet weak var buttonMaybe: UIButton!
    @IBOutlet weak var buttonCrush: UIButton!
    @IBOutlet weak var buttonLike: UIButton!
    var mainDataUserPhotosVideo = [UserPhotoVideoModel]()
    var dataUserPhotosVideo = [UserPhotoVideoModel]()
    var dataUserSavedQuestions = [PFObject]()
    var presenter = ProfilePresenter()
    var videoUrl = ""
    var isPhotosFetched = false
    var isDataFetched = false
    var user = PFUser()
    var crushObject: PFObject?
    var likeObject: PFObject?
    var maybeObject: PFObject?
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.presenter.getAllUploadedFilesForUser(currentUserId: user.objectId ?? "", shouldShowLoader: true, isFromViewDidLoad: true)
        self.presenter.getUserSavedQuestions(user: self.user, shouldShowLoader: false)
        if APP_MANAGER.session != self.user {
            self.disableUserInteractionButtons()
            self.presenter.getFansMarkedByMe(user: self.user)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    //MARK: - Helper Methods
    func registerTableViewCells() {
        self.tableViewUserQuestions.register(UINib(nibName: MyProfileTableViewCell.className, bundle: nil), forCellReuseIdentifier: MyProfileTableViewCell.className)
    }
    
    func setViews() {
        if self.user.objectId == APP_MANAGER.session!.objectId {
            self.stackViewMyProfileButtons.isHidden = false
            self.cstHeightOthersProfileStackView.constant = 0
            self.progressView.isHidden = true
            self.labelDistance.isHidden = true
            self.viewRefresh.isHidden = true
        } else {
            self.stackViewMyProfileButtons.isHidden = true
            self.cstHeightOthersProfileStackView.constant = 80
            self.viewRefresh.isHidden = false
            let userLocation = self.user.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            self.labelDistance.text = Utilities.shared.getDistance(userLocation: userLocation)
            let myUserOptions = self.getMyUserOptions()
            let percentage = self.getPercentageMatch(myUserOptions: myUserOptions, otherUser: self.user)
            self.labelMatchPercentage.text = "\(percentage)%\nMatch"
            self.labelDistance.isHidden = false
            self.progressView.isHidden = false
            self.progressView.startAngle = -90
            self.progressView.style = .ontop
            self.progressView.startProgress(to: CGFloat(percentage), duration: 0.1)
        }
        
    }
    
    func setProfileInfo() {
        self.labelName.text = self.user.value(forKey: DBColumn.nick) as? String ?? ""
        
        self.tableViewUserQuestions.reloadData {
            self.cstHeightTableView.constant = self.tableViewUserQuestions.contentSize.height
            self.tableViewUserQuestions.layoutIfNeeded()
            self.cstHeightTableView.constant = self.tableViewUserQuestions.contentSize.height
        }
        
        let aboutMeText = APP_MANAGER.session?.value(forKey: DBColumn.aboutMe) as? String ?? ""
        let stringToDisplay = aboutMeText == "" ? "" : "About Me: \(aboutMeText)"
        self.labelAboutMe.attributedText = self.attributedText(withString: stringToDisplay, boldString: "About Me:", font: UIFont(name: "OpenSans-Regular", size: 14)!)
        self.setViews()
    }
    
    func setPhotosVideo() {
        switch self.dataUserPhotosVideo.count {
        case 1:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.imageViewProfile2.image = UIImage()
            self.imageViewProfile3.image = UIImage()
            break
        case 2:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[1].uploadFileUrl ?? "", imageView: self.imageViewProfile2, placeholderImage: UIImage(named: "default_placeholder"))
            self.imageViewProfile3.image = UIImage()
            break
        case 3:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[1].uploadFileUrl ?? "", imageView: self.imageViewProfile2, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[2].uploadFileUrl ?? "", imageView: self.imageViewProfile3, placeholderImage: UIImage(named: "default_placeholder"))
            break
        default:
            self.imageViewProfile1.image = UIImage()
            self.imageViewProfile2.image = UIImage()
            self.imageViewProfile3.image = UIImage()
            break
        }
    }
    
    //MARK: - Button Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func maybeButtonPressed(_ sender: Any) {
        if self.maybeObject == nil {
            self.presenter.markUserAsFan(user: self.user, fanType: .maybe)
        } else {
            self.presenter.unmarkUserAsFan(object: self.maybeObject!, fanType: .maybe)
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if self.likeObject == nil {
            self.presenter.markUserAsFan(user: self.user, fanType: .like)
        } else {
            self.presenter.unmarkUserAsFan(object: self.likeObject!, fanType: .like)
        }
    }
    
    @IBAction func crushButtonPressed(_ sender: Any) {
        if self.crushObject == nil {
            self.presenter.markUserAsFan(user: self.user, fanType: .crush)
        } else {
            self.presenter.unmarkUserAsFan(object: self.crushObject!, fanType: .crush)
        }
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        self.presenter.getAllUploadedFilesForUser(currentUserId: user.objectId ?? "", shouldShowLoader: true, isFromViewDidLoad: true)
        self.presenter.getUserSavedQuestions(user: self.user, shouldShowLoader: false)
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        let vc = EditProfileVC(userSavedOptions: self.dataUserSavedQuestions)
        vc.isAnyInfoUpdated = { [weak self] status in
            if status {
                self?.presenter.getUserSavedQuestions(user: APP_MANAGER.session!, shouldShowLoader: true)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editMultimediaButtonPressed(_ sender: Any) {
        let vc = UploadPhotoVideoVC(data: self.mainDataUserPhotosVideo)
        vc.isAnyMediaUpdated = { [weak self] status in
            if status {
                self?.presenter.getAllUploadedFilesForUser(currentUserId: APP_MANAGER.session?.objectId ?? "", shouldShowLoader: true, isFromViewDidLoad: false)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func videoButtonPressed(_ sender: Any) {
        self.playVideo(filePath: self.videoUrl)
    }
    
    func enableUserInteractionButtons() {
        self.buttonMaybe.isUserInteractionEnabled = true
        self.buttonLike.isUserInteractionEnabled = true
        self.buttonCrush.isUserInteractionEnabled = true
        
        if likeObject != nil {
            self.buttonLike.alpha = 1
        } else {
            self.buttonLike.alpha = 0.5
        }
        
        if crushObject != nil {
            self.buttonCrush.alpha = 1
        } else {
            self.buttonCrush.alpha = 0.5
        }
        
        if maybeObject != nil {
            self.buttonMaybe.alpha = 1
        } else {
            self.buttonMaybe.alpha = 0.5
        }
    }
    
    func disableUserInteractionButtons() {
        self.buttonMaybe.isUserInteractionEnabled = false
        self.buttonLike.isUserInteractionEnabled = false
        self.buttonCrush.isUserInteractionEnabled = false
    }
    
}

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyProfileTableViewCell.className, for: indexPath) as! MyProfileTableViewCell
        cell.data = self.dataUserSavedQuestions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataUserSavedQuestions.count
    }
}

extension ProfileVC: ProfileDelegate {
    func profile(isSuccess: Bool, userFilesData: [PFObject], msg: String) {
        self.self.mainDataUserPhotosVideo.removeAll()
        if isSuccess {
            for i in userFilesData {
                let uploadedFile = i[DBColumn.file] as? PFFileObject
                let model = UserPhotoVideoModel(uploadFileUrl: uploadedFile?.url ?? "", object: i)
                self.mainDataUserPhotosVideo.append(model)
            }
            self.dataUserPhotosVideo = self.presenter.getUserPhotosVideos(data: self.mainDataUserPhotosVideo, isPhotos: true)
            let userVideo = self.presenter.getUserPhotosVideos(data: self.mainDataUserPhotosVideo, isPhotos: false)
            if userVideo.count > 0 {
                self.cstTopImageView.constant = 8
                self.viewVideo.isHidden = false
                self.videoUrl = userVideo[0].uploadFileUrl!
                if let img = self.getVideoThumbnail(from: self.videoUrl) {
                    self.imageViewVideo.image = img
                }
                self.cstTopImageView.constant = 8
                self.viewVideo.isHidden = false
            } else {
                self.cstTopImageView.constant = -60
                self.viewVideo.isHidden = true
            }
            
            self.isPhotosFetched = true
            self.setPhotosVideo()
            if self.isDataFetched && self.isPhotosFetched {
                self.viewBlocker.isHidden = true
                SVProgressHUD.dismiss()
            }
            
        }
    }
    
    func profile(isSuccess: Bool, userSavedQuestions: [PFObject], msg: String) {
        if isSuccess {
            self.dataUserSavedQuestions = [PFObject]()
            for i in userSavedQuestions {
                let optionsObjArray = i.value(forKey: DBColumn.optionsObjArray) as? [PFObject]
                if optionsObjArray?.count ?? 0 > 0 {
                    //only append if user has marked any options in the given question
                    self.dataUserSavedQuestions.append(i)
                }
            }
            self.isDataFetched = true
            self.setProfileInfo()
            if self.isDataFetched && self.isPhotosFetched {
                self.viewBlocker.isHidden = true
                SVProgressHUD.dismiss()
            }
        } else {
            self.showToast(message: msg)
        }
    }

    func profile(isSuccess: Bool, msg: String, markedUnmarkedUserFanType: FanType, isDeleted: Bool, object: PFObject?) {
        if isDeleted == false { //saving case
            self.showToast(message: msg)
            if isSuccess {
                switch markedUnmarkedUserFanType {
                case .like:
                    self.likeObject = object
                    break
                case .maybe:
                    self.maybeObject = object
                    break
                case .crush:
                    self.crushObject = object
                    break
                }
                self.enableUserInteractionButtons()
            }
        } else { //deleting case
            if isSuccess {
                switch markedUnmarkedUserFanType {
                case .like:
                    self.likeObject = object
                    break
                case .maybe:
                    self.maybeObject = object
                    break
                case .crush:
                    self.crushObject = object
                    break
                }
                self.enableUserInteractionButtons()
            } else {
                self.showToast(message: msg)
            }
        }
    }
    
    func profile(isSuccess: Bool, msg: String, fansMarkedByMe: [PFObject]) {
        if isSuccess {
            for i in fansMarkedByMe {
                let fanType = i.value(forKey: DBColumn.fanType) as? String ?? ""
                switch fanType {
                case FanType.like.rawValue:
                    self.likeObject = i
                case FanType.maybe.rawValue:
                    self.maybeObject = i
                case FanType.crush.rawValue:
                    self.crushObject = i
                default:
                    break
                }
            }
            self.enableUserInteractionButtons()
        } else {
            if msg != "No data found" {
                self.showToast(message: msg)
            } else {
                self.enableUserInteractionButtons()
            }
        }
    }
}
