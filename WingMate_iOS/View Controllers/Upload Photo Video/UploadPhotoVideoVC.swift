//
//  UploadPhotoVideoVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 22/12/2020.
//

import UIKit
import UICircularProgressRing
import Parse

class UploadPhotoVideoVC: BaseViewController {
    
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var collectionViewPhotos: UICollectionView!
    @IBOutlet weak var constraintHeightCollectionViewPhotos: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTerms: UICollectionView!
    @IBOutlet weak var constraintHeightCollectionViewTerms: NSLayoutConstraint!
    @IBOutlet weak var tableViewTerms: UITableView!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var progressView: UICircularProgressRing!
    @IBOutlet weak var constraintHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var scrollViewMain: UIScrollView!
    @IBOutlet weak var testimageview: UIImageView!
    var isPhotoMode = true
    var isPhotosUploaded = false

    let imagePicker = UIImagePickerController()
    var selectedImageIndex = 0
    let maximumNumberOfPhotosAllowed = 3
    var isAnyMediaUpdated: ((Bool)->Void)?
    var isPhotoVideoUpdated = false
    var shouldGetData = false
    
    var dataTermsConditions: [PFObject]?
    var dataTextTerms: [TextTypeTerms]?
    var dataPhotoTerms: [PhotoVideoTypeTerms]?
    var dataUserPhotoVideo = [UserPhotoVideoModel()]
    var mainDataUserPhotosVideo = [UserPhotoVideoModel()]
    var presenter = UploadPhotoVideoPresenter()
    var presenterProfile = ProfilePresenter()
    var isTrialExpired = false
    
    convenience init(data: [UserPhotoVideoModel]) {
        self.init()
        self.mainDataUserPhotosVideo = data
    }
    
    convenience init(shouldGetData: Bool, isTrialExpired: Bool) {
        self.init()
        self.shouldGetData = shouldGetData
        self.isTrialExpired = isTrialExpired
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.presenterProfile.attach(vc: self)
        self.registerCells()
        self.initialLayout()
        
        self.presenter.getTermsConditions()
        if self.shouldGetData {
            self.presenterProfile.getAllUploadedFilesForUser(currentUserId: PFUser.current()?.value(forKey: DBColumn.objectId) as? String ?? "", shouldShowLoader: true, isFromViewDidLoad: true)
        } else {
            self.goToPhotos()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.setTermsViewsHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    

    //MARK: - Helper Methods
    func initialLayout() {
        self.imagePicker.delegate = self
        self.setInitialProgressView()
    }
    
    func registerCells() {
        self.collectionViewPhotos.register(UINib(nibName: UploadPhotoVideoCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: UploadPhotoVideoCollectionViewCell.className)
        self.tableViewTerms.register(UINib(nibName: String(describing: TermsConditionsTableViewCell.self), bundle: Bundle.main), forCellReuseIdentifier: TermsConditionsTableViewCell.className)
        self.collectionViewTerms.register(UINib(nibName: TermsConditionsCollectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: TermsConditionsCollectionViewCell.className)
    }
    
    func setInitialProgressView() {
        self.progressView.style = .ontop
        self.progressView.minValue = 1
        self.progressView.maxValue = 2
        self.progressView.startAngle = -90
        self.setProgress()
    }
    
    func setProgress() {
        self.labelProgress.text = self.isPhotoMode ? "1/2" : "2/2"
        self.progressView.startProgress(to: self.isPhotoMode ? 1 : 2, duration: 0.1)
        self.labelHeading.text = self.isPhotoMode ? "Upload Photos" : "Upload Videos"
        self.labelSubHeading.text = self.isPhotoMode ? "Minimum 1 photo is required" : "Video is required"
    }
    
    func setPhotosCollectionViewHeight() {
        self.collectionViewPhotos.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.constraintHeightCollectionViewPhotos.constant = self.collectionViewPhotos.contentSize.height
        })
    }
    
    func setTermsViewsHeight() {
        self.tableViewTerms.reloadData()
        self.collectionViewTerms.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.constraintHeightTableView.constant = self.tableViewTerms.contentSize.height
            self.tableViewTerms.layoutIfNeeded()
            self.constraintHeightTableView.constant = self.tableViewTerms.contentSize.height
            self.constraintHeightCollectionViewTerms.constant = self.collectionViewTerms.contentSize.height
            self.view.layoutIfNeeded()
        })
    }
    
    func goToVideos() {
        self.isPhotoMode = false
        self.getTermsConditions()
        self.setProgress()
        
        self.imagePicker.mediaTypes = ["public.movie"]
        self.dataUserPhotoVideo = self.presenter.getUserFiles(isPhotoMode: self.isPhotoMode, data: self.mainDataUserPhotosVideo, maxPhotosAllowed: self.maximumNumberOfPhotosAllowed)
        if self.dataUserPhotoVideo.count == 0 {
            self.dataUserPhotoVideo = [UserPhotoVideoModel()]
        }
        self.setPhotosCollectionViewHeight()
        self.scrollViewMain.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func goToPhotos() {
        self.isPhotoMode = true
        self.getTermsConditions()
        self.setProgress()
        
        self.dataUserPhotoVideo = self.presenter.getUserFiles(isPhotoMode: self.isPhotoMode, data: self.mainDataUserPhotosVideo, maxPhotosAllowed: self.maximumNumberOfPhotosAllowed)
//        if self.dataUserPhotoVideo.count < 3 {
//            self.dataUserPhotoVideo.append(UserPhotoVideoModel())
//        }
        self.setPhotosCollectionViewHeight()
        self.scrollViewMain.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func getTermsConditions() {
        self.dataTextTerms = self.presenter.getTermsConditionsText(isPhotoMode: self.isPhotoMode, dataTermsConditions: self.dataTermsConditions)
        self.scrollViewMain.scrollToTop()
        self.dataPhotoTerms = self.presenter.getTermsConditionsImages(isPhotoMode: self.isPhotoMode, dataTermsConditions: self.dataTermsConditions)
        self.setTermsViewsHeight()
    }
    
    //MARK: - Button Actions
    @IBAction func saveButtonPressed(_ sender: Any) {
        if self.isPhotoMode {
            if self.isTrialExpired {
                if self.dataUserPhotoVideo[0].uploadFileUrl == nil {
                    self.showToast(message: ValidationStrings.uploadAtleast1Photo)
                } else {
                    self.goToVideos()
                }
            } else {
                if self.dataUserPhotoVideo[0].uploadFileUrl == nil {
                    self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.min1PhotoRequired, successHandler: { successAction in
                        self.goToVideos()
                    }, failureHandler: { failureAction in })
                } else {
                    self.isPhotosUploaded = true
                    self.goToVideos()
                }
            }
        } else {
            if self.isTrialExpired {
                if self.dataUserPhotoVideo[0].uploadFileUrl == nil {
                    self.showToast(message: ValidationStrings.uploadVideoToContinue)
                } else {
                    let vc = CongratsVC(isPhotosVideoUploadedFlow: true)
                    vc.isTrialExpired = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if self.dataUserPhotoVideo[0].uploadFileUrl == nil {
                    self.showAlertTwoButtons(APP_NAME, message: ValidationStrings.min1videoRequired, successHandler: { successAction in
                        self.navigationController?.popToRootViewController(animated: true)
                    }, failureHandler: { failureAction in })
                } else {
                    if self.isPhotosUploaded {
                        let vc = CongratsVC(isPhotosVideoUploadedFlow: true)
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
        }
    }
    
        //        self.isAnyMediaUpdated?(self.isPhotoVideoUpdated)
        //        self.navigationController?.popViewController(animated: true)

    @IBAction func backButtonPressed(_ sender: Any) {
//        if self.isPhotoMode {
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            self.goToPhotos()
//        }
        self.isAnyMediaUpdated?(self.isPhotoVideoUpdated)
        if self.isTrialExpired {
            self.showToast(message: "Trial period has been expired")
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
}

//MARK: - Collection View Delegates
extension UploadPhotoVideoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewPhotos {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UploadPhotoVideoCollectionViewCell.className, for: indexPath) as! UploadPhotoVideoCollectionViewCell
            cell.indexPath = indexPath
            cell.isPhotoMode = self.isPhotoMode
            cell.data = self.dataUserPhotoVideo[indexPath.item]
            cell.removeImageButtonPressed = { [weak self] buttonTag in
                self?.showAlertTwoButtons(APP_NAME, message: ValidationStrings.deletingAlertMsg, successHandler: { successAction in
                    self?.presenter.removePhotoVideoFileFromServer(obj: self?.dataUserPhotoVideo[buttonTag].object ?? PFObject(className: "abc"), index: buttonTag)
                }, failureHandler: { failureAction in
                    
                })
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TermsConditionsCollectionViewCell.className, for: indexPath) as! TermsConditionsCollectionViewCell
            cell.indexPath = indexPath
            if let dta = self.dataPhotoTerms?[indexPath.item] {
                cell.isPhotoMode = self.isPhotoMode
                cell.data = dta
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionViewPhotos {
            if !self.isPhotoMode {
                if self.dataUserPhotoVideo[indexPath.item].uploadFileUrl == nil {
                    self.selectedImageIndex = indexPath.item
//                    imagePicker.allowsEditing = true
                    imagePicker.sourceType = .photoLibrary
                    self.present(imagePicker, animated: true, completion: nil)
                } else {
                    self.playVideo(filePath: self.dataUserPhotoVideo[0].uploadFileUrl ?? "")
                }
            } else {
                if self.dataUserPhotoVideo[indexPath.item].uploadFileUrl == nil {
                    self.selectedImageIndex = indexPath.item
                    self.addImagePicker(title: nil, msg: nil, imagePicker: self.imagePicker)
                }
            }
        } else { //terms conditions collection view
            if !self.isPhotoMode {
                self.playVideo(filePath: (self.dataPhotoTerms?[indexPath.item].fileUrl!)!)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.collectionViewPhotos ? self.dataUserPhotoVideo.count : self.dataPhotoTerms?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionViewPhotos {
            let cell1Size = CGSize(width: self.collectionViewPhotos.frame.width, height: 240)
            let cell2Size = CGSize(width: self.collectionViewPhotos.frame.width/4, height: self.collectionViewPhotos.frame.width/4)
            if self.dataUserPhotoVideo.count == 1 {
                return cell1Size
            } else {
                if indexPath.item == 0 {
                    return cell1Size
                } else {
                    return cell2Size
                }
            }
        } else {
            return CGSize(width: self.collectionViewPhotos.frame.width/2, height: self.collectionViewPhotos.frame.width/2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.collectionViewPhotos {
            if collectionView.numberOfItems(inSection: section) == 2 {
                let cellWidth = self.collectionViewPhotos.frame.width/4
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - cellWidth)
            }
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            if collectionView.numberOfItems(inSection: section) == 1 {
                let cellWidth = self.collectionViewPhotos.frame.width/2
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: collectionView.frame.width - cellWidth)
            }
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
}

//MARK: - Table View Delegates
extension UploadPhotoVideoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TermsConditionsTableViewCell.className, for: indexPath) as! TermsConditionsTableViewCell
        if let dta = self.dataTextTerms?[indexPath.row] {
            cell.data = dta
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataTextTerms?.count ?? 0
    }
}

//MARK: - Image Picker Delegates
extension UploadPhotoVideoVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if self.isPhotoMode {
            if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                self.presenter.savePhotoVideoFileToServer(pickedImage: pickedImage)
            }
        } else {
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            print("videoURL:\(String(describing: videoURL))")
            self.presenter.savePhotoVideoFileToServer(videoUrl: videoURL)
        }
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Network Call Backs
extension UploadPhotoVideoVC: UploadPhotoVideoDelegate {
    
    func uploadPhotoVideo(isSuccess: Bool, termsData: [PFObject], msg: String) {
        if isSuccess {
            self.dataTermsConditions = termsData
            self.dataTextTerms = self.presenter.getTermsConditionsText(isPhotoMode: self.isPhotoMode, dataTermsConditions: self.dataTermsConditions)
            self.dataPhotoTerms = self.presenter.getTermsConditionsImages(isPhotoMode: self.isPhotoMode, dataTermsConditions: self.dataTermsConditions)
            self.setTermsViewsHeight()
        } else {
            self.showToast(message: msg)
        }
    }
    
    func uploadPhotoVideo(isFileUploaded: Bool, msg: String, fileUrl: String?, obj: PFObject) {
        self.showToast(message: msg)
        if isFileUploaded {
            self.isPhotoVideoUpdated = true
            if self.isPhotoMode {
                if fileUrl != nil { //image uploaded
                    let model = UserPhotoVideoModel(uploadFileUrl: fileUrl!, object: obj, fileStatus: FileStatus.pending.rawValue)
                    if self.maximumNumberOfPhotosAllowed == self.dataUserPhotoVideo.count {
                        self.dataUserPhotoVideo[self.maximumNumberOfPhotosAllowed-1] = model
                    } else {
                        self.dataUserPhotoVideo.insert(model, at: self.dataUserPhotoVideo.count-1)
                    }
//                    self.updateUserProfilePic()
                    
                    PFUser.current()?.setValue(true, forKey: DBColumn.isPhotosSubmitted)
                    self.presenter.updateUserObject()
                } else {
                    self.showToast(message: "Nil photo file url")
                }
            } else {
                self.dataUserPhotoVideo[0] = UserPhotoVideoModel(uploadFileUrl: fileUrl!, object: obj, fileStatus: FileStatus.pending.rawValue)
                self.dataUserPhotoVideo[0].image = self.getVideoThumbnail(from: fileUrl!)
                
                PFUser.current()?.setValue(true, forKey: DBColumn.isVideoSubmitted)
                self.presenter.updateUserObject()
            }
            self.setPhotosCollectionViewHeight()
        }
    }
    
    func updateUserProfilePic() {
        /*if self.dataUserPhotoVideo.count > 1 {
            PFUser.current()?.setValue(self.dataUserPhotoVideo[0].uploadFileUrl ?? "", forKey: DBColumn.profilePic)
            ParseAPIManager.updateUserObject() { (success) in
                if success {
                    APP_MANAGER.session = PFUser.current()
                } else {
                }
            } onFailure: { (error) in
                self.showToast(message: error)
            }
        } else {
            PFUser.current()?.setValue("", forKey: DBColumn.profilePic)
            PFUser.current()?.setValue(false, forKey: DBColumn.isPhotosSubmitted)
            PFUser.current()?.setValue(UserAccountStatus.pending.rawValue, forKey: DBColumn.accountStatus)
            self.presenter.updateUserObject()
        }*/
    }
    
    func uploadPhotoVideo(isFileDeleted: Bool, msg: String, index: Int) {
        self.showToast(message: msg)
        if isFileDeleted {
            self.isPhotoVideoUpdated = true
            if self.isPhotoMode {
                self.dataUserPhotoVideo.remove(at: index)
                if self.dataUserPhotoVideo.count < 3 {
                    var shouldAddEmptyBox = true
                    for i in self.dataUserPhotoVideo {
                        if i.uploadFileUrl == nil {
                            shouldAddEmptyBox = false
                            break
                        }
                    }
                    if shouldAddEmptyBox {
                        self.dataUserPhotoVideo.append(UserPhotoVideoModel())
                    }
                }
                self.updateUserProfilePic()
            } else {
                self.dataUserPhotoVideo[0] = UserPhotoVideoModel()
                PFUser.current()?.setValue(false, forKey: DBColumn.isVideoSubmitted)
                PFUser.current()?.setValue(UserAccountStatus.pending.rawValue, forKey: DBColumn.accountStatus)
                self.presenter.updateUserObject()
            }
            self.setPhotosCollectionViewHeight()
        }
    }
    
    
}

extension UploadPhotoVideoVC: ProfileDelegate {
    func profile(isSuccess: Bool, userFilesData: [PFObject], msg: String) {
        self.mainDataUserPhotosVideo.removeAll()
        if isSuccess {
            for i in userFilesData {
                let uploadedFile = i[DBColumn.file] as? PFFileObject
                let fileStatus = i[DBColumn.fileStatus] as? Int ?? -1
                let model = UserPhotoVideoModel(uploadFileUrl: uploadedFile?.url ?? "", object: i, fileStatus: fileStatus)
                self.mainDataUserPhotosVideo.append(model)
            }
            self.goToPhotos()
        }
    }
    
    func profile(isSuccess: Bool, userSavedQuestions: [PFObject], msg: String) {}
    
    func profile(isSuccess: Bool, msg: String, markedUnmarkedUserFanType: FanType, isDeleted: Bool, object: PFObject?) {}
    
    func profile(isSuccess: Bool, msg: String, fansMarkedByMe: [PFObject]) {}
    
    
}
