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
import ImageSlideShowSwift

class ProfileVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var imageViewProfile1: UIImageView!
    @IBOutlet weak var buttonProfileImage1: UIButton!
    @IBOutlet weak var imageViewProfile2: UIImageView!
    @IBOutlet weak var buttonProfileImage2: UIButton!
    @IBOutlet weak var imageViewProfile3: UIImageView!
    @IBOutlet weak var buttonProfileImage3: UIButton!
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
    var refreshFansList:(()->Void)?
    var isTrialExpired = false
    var isLaunchCampaign = false
    
    convenience init(user: PFUser) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let launchPay = UserDefaults.standard.object(forKey: UserDefaultKeys.userObjectKeyUserDefaults){
            self.isLaunchCampaign = launchPay as! Bool
        }
        self.processUserState()
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
        self.tabBarController?.tabBar.isHidden = true
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
            self.setAboutMeText(usr: PFUser.current()!)
        } else {
            self.stackViewMyProfileButtons.isHidden = true
            self.cstHeightOthersProfileStackView.constant = 80
            self.viewRefresh.isHidden = false
            self.setAboutMeText(usr: self.user)
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
    
    func setAboutMeText(usr: PFUser) {
        let aboutMeText = usr.value(forKey: DBColumn.aboutMe) as? String ?? ""
        let stringToDisplay = aboutMeText == "" ? "" : "About Me: \(aboutMeText)"
        self.labelAboutMe.attributedText = self.attributedText(withString: stringToDisplay, boldString: "About Me:", font: UIFont(name: "OpenSans-Regular", size: 14)!)
    }
    
    func setProfileInfo() {
        self.labelName.text = self.user.value(forKey: DBColumn.nick) as? String ?? ""
        
        self.tableViewUserQuestions.reloadData {
            self.cstHeightTableView.constant = self.tableViewUserQuestions.contentSize.height
            self.tableViewUserQuestions.layoutIfNeeded()
            self.cstHeightTableView.constant = self.tableViewUserQuestions.contentSize.height
        }
        
        
        self.setViews()
    }
    
    func setPhotosVideo() {
        switch self.dataUserPhotosVideo.count {
        case 1:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.imageViewProfile2.image = UIImage()
            self.imageViewProfile3.image = UIImage()
            self.buttonProfileImage1.isHidden = false
            self.buttonProfileImage2.isHidden = true
            self.buttonProfileImage3.isHidden = true
            break
        case 2:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[1].uploadFileUrl ?? "", imageView: self.imageViewProfile2, placeholderImage: UIImage(named: "default_placeholder"))
            self.imageViewProfile3.image = UIImage()
            self.buttonProfileImage1.isHidden = false
            self.buttonProfileImage2.isHidden = false
            self.buttonProfileImage3.isHidden = true
            break
        case 3:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[1].uploadFileUrl ?? "", imageView: self.imageViewProfile2, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[2].uploadFileUrl ?? "", imageView: self.imageViewProfile3, placeholderImage: UIImage(named: "default_placeholder"))
            self.buttonProfileImage1.isHidden = false
            self.buttonProfileImage2.isHidden = false
            self.buttonProfileImage3.isHidden = false
            break
        default:
            self.imageViewProfile1.image = UIImage()
            self.imageViewProfile2.image = UIImage()
            self.imageViewProfile3.image = UIImage()
            self.buttonProfileImage1.isHidden = true
            self.buttonProfileImage2.isHidden = true
            self.buttonProfileImage3.isHidden = true
            break
        }
    }
    
    func showImagesInSlider(indexSelected: Int) {
        var images: [Image] = []
        for i in self.dataUserPhotosVideo {
            images.append(Image(title: "", url: URL(string: i.uploadFileUrl ?? "")!))
        }
        
        ImageSlideShowViewController.presentFrom(self){ [weak self] controller in
            
            controller.dismissOnPanGesture = true
            controller.slides = images
            controller.initialIndex = indexSelected
            controller.enableZoom = true
            controller.controllerDidDismiss = {
                debugPrint("Controller Dismissed")
                
                debugPrint("last index viewed: \(controller.currentIndex)")
            }
            
            controller.slideShowViewDidLoad = {
                debugPrint("Did Load")
            }
            
            controller.slideShowViewWillAppear = { animated in
                debugPrint("Will Appear Animated: \(animated)")
            }
            
            controller.slideShowViewDidAppear = { animated in
                debugPrint("Did Appear Animated: \(animated)")
            }
            
        }
    }
    
    func processUserState() {
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
                self.isTrialExpired = isExpired
                if isExpired {
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
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToPayNowTrialExpired) { action in
                            if self.isLaunchCampaign == false {
                            let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                            self.navigationController?.pushViewController(vc, animated: true)
                            }else {
                                let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                    } else if isPaidUser && !isMandatoryQuestionsFilled && status == UserAccountStatus.accepted.rawValue{
                        self.showAlertOK(APP_NAME, message: ValidationStrings.needToFillMandatoryQuestionnaires) { action in
                            let vc = QuestionnairesVC(isMandatoryQuestionnaires: true)
                            vc.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                        
                        
                    }
                }
            }
        })
    }
    
    //MARK: - Button Actions
    @IBAction func image1ButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile1)
        self.showImagesInSlider(indexSelected: 0)
    }
    
    @IBAction func image2ButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile2)
        self.showImagesInSlider(indexSelected: 1)
    }
    
    @IBAction func image3ButtonPressed(_ sender: Any) {
//        self.previewImage(imageView: self.imageViewProfile3)
        self.showImagesInSlider(indexSelected: 2)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isAllowedToInteract() -> Bool {
        let isPaid = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
        let isActive = PFUser.current()?.value(forKey: DBColumn.accountStatus) as? Int ?? 0
        
        if isPaid && (isActive == UserAccountStatus.accepted.rawValue) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func maybeButtonPressed(_ sender: Any) {
        if self.user.value(forKey:"likeDisabled") as? Bool == true {
            self.showAlertOK("Blinqui", message: "User maybe is disabled")
        }else {
            self.interactWithUsers(interactionType: .maybe)
        }
       
    }

    
    @IBAction func likeButtonPressed(_ sender: Any) {
        if self.user.value(forKey:"likeDisabled") as? Bool == true {
            self.showAlertOK("Blinqui", message: "User like is disabled")
        }else {
            self.interactWithUsers(interactionType: .like)
        }
       
    }
    
    @IBAction func crushButtonPressed(_ sender: Any) {
        if self.user.value(forKey:"likeDisabled") as? Bool == true {
            self.showAlertOK("Blinqui", message: "User crush is disabled")
        }else {
            self.interactWithUsers(interactionType: .crush)
        }

       
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        if self.user.value(forKey:"messageDisabled") as? Bool == true {
            self.showAlertOK("Blinqui", message: "User message is disabled")
        }else {
            let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
            let isPhotosSubmitted = PFUser.current()?.value(forKey: DBColumn.isPhotosSubmitted) as? Bool ?? false
            let isVideoSubmitted = PFUser.current()?.value(forKey: DBColumn.isVideoSubmitted) as? Bool ?? false
            let status = PFUser.current()?.value(forKey: DBColumn.accountStatus) as? Int ?? UserAccountStatus.pending.rawValue
            
            if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
                self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.uploadMediaAndBecomePaidToInteract, rightBtnText: ValidationStrings.uploadNow, leftBtnText: ValidationStrings.uploadLater) { rightButtonAction in
                    let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: self.isTrialExpired)
                    self.navigationController?.pushViewController(vc, animated: true)
                } failureHandler: { leftButtonAction in
                    
                }
            } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
                self.showAlertOK(APP_NAME, message: ValidationStrings.accountInReviewForInteraction)
            } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.becomePaidUser, rightBtnText: ValidationStrings.payNow, leftBtnText: ValidationStrings.payLater) { rightButtonAction in
                    if self.isLaunchCampaign == false {
                    let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } failureHandler: { leftButtonAction in
                    
                }
            }else {
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let vc = storyboard.instantiateViewController(withIdentifier: "Messages") as! MessagesVC
                vc.userObj = user
                navigationController?.pushViewController(vc, animated: true)
            }
        }


    }
    
    func interactWithUsers(interactionType: InteractionType) {
        let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
        let isPhotosSubmitted = PFUser.current()?.value(forKey: DBColumn.isPhotosSubmitted) as? Bool ?? false
        let isVideoSubmitted = PFUser.current()?.value(forKey: DBColumn.isVideoSubmitted) as? Bool ?? false
        let status = PFUser.current()?.value(forKey: DBColumn.accountStatus) as? Int ?? UserAccountStatus.pending.rawValue
        
        if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
            self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.uploadMediaAndBecomePaidToInteract, rightBtnText: ValidationStrings.uploadNow, leftBtnText: ValidationStrings.uploadLater) { rightButtonAction in
                let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: self.isTrialExpired)
                self.navigationController?.pushViewController(vc, animated: true)
            } failureHandler: { leftButtonAction in
                
            }
        } else if (isPhotosSubmitted && isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
            self.showAlertOK(APP_NAME, message: ValidationStrings.accountInReviewForInteraction)
        } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
            self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.becomePaidUser, rightBtnText: ValidationStrings.payNow, leftBtnText: ValidationStrings.payLater) { rightButtonAction in
                if self.isLaunchCampaign == false {
                let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                self.navigationController?.pushViewController(vc, animated: true)
                }else {
                    let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } failureHandler: { leftButtonAction in
                
            }
        } else {
            //can interact now
            if interactionType == .maybe {
                if self.maybeObject == nil {
                    self.presenter.markUserAsFan(user: self.user, fanType: .maybe)
                } else {
                    self.presenter.unmarkUserAsFan(object: self.maybeObject!, fanType: .maybe)
                }
            } else if interactionType == .like {
                if self.likeObject == nil {
                    self.presenter.markUserAsFan(user: self.user, fanType: .like)
                } else {
                    self.presenter.unmarkUserAsFan(object: self.likeObject!, fanType: .like)
                }
            } else if interactionType == .crush {
                if self.crushObject == nil {
                    self.presenter.markUserAsFan(user: self.user, fanType: .crush)
                } else {
                    self.presenter.unmarkUserAsFan(object: self.crushObject!, fanType: .crush)
                }
            }
        }
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        self.presenter.getAllUploadedFilesForUser(currentUserId: user.objectId ?? "", shouldShowLoader: true, isFromViewDidLoad: true)
        self.presenter.getUserSavedQuestions(user: self.user, shouldShowLoader: false)
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        let isPaidUser = PFUser.current()?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
        let isPhotosSubmitted = PFUser.current()?.value(forKey: DBColumn.isPhotosSubmitted) as? Bool ?? false
        let isVideoSubmitted = PFUser.current()?.value(forKey: DBColumn.isVideoSubmitted) as? Bool ?? false
        let status = PFUser.current()?.value(forKey: DBColumn.accountStatus) as? Int ?? 0
        
        if isPaidUser {
            let vc = EditProfileVC(userSavedOptions: self.dataUserSavedQuestions)
            vc.isAnyInfoUpdated = { [weak self] status in
                if status {
                    self?.presenter.getUserSavedQuestions(user: APP_MANAGER.session!, shouldShowLoader: true)
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            if status == UserAccountStatus.pending.rawValue && (!isPhotosSubmitted || !isVideoSubmitted) {
                self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.uploadMediaFirst) { successAction in
                    let vc = UploadPhotoVideoVC(shouldGetData: true, isTrialExpired: self.isTrialExpired)
                    self.navigationController?.pushViewController(vc, animated: true)
                } failureHandler: { failureAction in
                    
                }
            } else if (isPhotosSubmitted || isVideoSubmitted) && status == UserAccountStatus.pending.rawValue {
                self.showAlertOK(APP_NAME, message: ValidationStrings.accountInReviewForInteraction)
            } else if !isPaidUser && status == UserAccountStatus.accepted.rawValue {
                self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.payNowToCompleteProfile) { successAction in
                    if self.isLaunchCampaign == false {
                    let vc = SelectPaymentOptionVC(nibName: "SelectPaymentOptionVC", bundle: nil)
                    self.navigationController?.pushViewController(vc, animated: true)
                    }else {
                        let vc = LaunchCampaignVC(nibName: "LaunchCampaignVC", bundle: nil)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } failureHandler: { failureAction in
                    
                }
            }
        }
    }
    
    @IBAction func editMultimediaButtonPressed(_ sender: Any) {
        let vc = UploadPhotoVideoVC(data: self.mainDataUserPhotosVideo)
        vc.isTrialExpired = self.isTrialExpired
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
            self.buttonLike.setImage(UIImage(named: "like-filled"), for: .normal)
        } else {
            self.buttonLike.setImage(UIImage(named: "profile_like"), for: .normal)
        }
        
        if crushObject != nil {
            self.buttonCrush.setImage(UIImage(named: "crush-filled"), for: .normal)
        } else {
            self.buttonCrush.setImage(UIImage(named: "profile_crush"), for: .normal)
        }
        
        if maybeObject != nil {
            self.buttonMaybe.setImage(UIImage(named: "maybe-filled"), for: .normal)
        } else {
            self.buttonMaybe.setImage(UIImage(named: "profile_maybe"), for: .normal)
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
        self.mainDataUserPhotosVideo.removeAll()
        if isSuccess {
            for i in userFilesData {
                let uploadedFile = i[DBColumn.file] as? PFFileObject
                let fileStatus = i[DBColumn.fileStatus] as? Int ?? -1
                let model = UserPhotoVideoModel(uploadFileUrl: uploadedFile?.url ?? "", object: i, fileStatus: fileStatus)
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
      //  let nickName = self.user.value(forKey: DBColumn.nick) as? String ?? ""
        let nickName = APP_MANAGER.session?.value(forKey: DBColumn.nick) as? String ?? ""
        if isDeleted == false { //saving case
//            self.showToast(message: msg)
            if isSuccess {
                switch markedUnmarkedUserFanType {
                case .like:
                    self.likeObject = object
                    self.presenter.pushNotification(title: APP_NAME, msg: "\(nickName) liked you", userId: self.user.objectId!)
                    break
                case .maybe:
                    self.maybeObject = object
                    self.presenter.pushNotification(title: APP_NAME, msg: "You are marked as maybe by \(nickName)", userId: self.user.objectId!)
                    break
                case .crush:
                    self.crushObject = object
                    self.presenter.pushNotification(title: APP_NAME, msg: "You are marked as crush by \(nickName)", userId: self.user.objectId!)
                    break
                }
                self.enableUserInteractionButtons()
                self.refreshFansList?()
            }
        } else { //deleting case
            if isSuccess {
                switch markedUnmarkedUserFanType {
                case .like:
                    self.likeObject = object
                    self.presenter.pushNotification(title: APP_NAME, msg: "\(nickName) unliked you", userId: self.user.objectId!)
                    break
                case .maybe:
                    self.maybeObject = object
                    self.presenter.pushNotification(title: APP_NAME, msg: "You are unmarked as maybe by \(nickName)", userId: self.user.objectId!)
                    break
                case .crush:
                    self.crushObject = object
                    self.presenter.pushNotification(title: APP_NAME, msg: "You are unmarked as crush by \(nickName)", userId: self.user.objectId!)
                    break
                }
                self.enableUserInteractionButtons()
                self.refreshFansList?()
            } else {
//                self.showToast(message: msg)
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


class Image: NSObject, ImageSlideShowProtocol
{
    private let url: URL
    let title: String?
    
    init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
    
    func slideIdentifier() -> String {
        return String(describing: url)
    }
    
    func image(completion: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: self.url) { data, response, error in
            
            if let data = data, error == nil
            {
                let image = UIImage(data: data)
                completion(image, nil)
            }
            else
            {
                completion(nil, error)
            }
            
        }.resume()
        
    }
}
