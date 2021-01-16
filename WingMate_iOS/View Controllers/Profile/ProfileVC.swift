//
//  ProfileVC.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/01/2021.
//

import UIKit
import UICircularProgressRing
import Parse

class ProfileVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var imageViewProfile1: UIImageView!
    @IBOutlet weak var imageViewProfile2: UIImageView!
    @IBOutlet weak var imageViewProfile3: UIImageView!
    @IBOutlet weak var imageViewVideo: UIImageView!
    @IBOutlet weak var labelNationality: UILabel!
    @IBOutlet weak var labelAge: UILabel!
    @IBOutlet weak var labelHeight: UILabel!
    @IBOutlet weak var labelLookingFor: UILabel!
    @IBOutlet weak var labelAboutMe: UILabel!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var cstHeightStackView: NSLayoutConstraint!
    @IBOutlet weak var stackViewMyProfileButtons: UIStackView!
    @IBOutlet weak var stackViewOthersProfileButtons: UIStackView!
    @IBOutlet weak var progressView: UICircularProgressRing!
    @IBOutlet weak var labelMatchPercentage: UILabel!
    var mainDataUserPhotosVideo = [UserPhotoVideoModel]()
    var dataUserPhotosVideo = [UserPhotoVideoModel]()
    var dataUserSavedQuestions = [PFObject]()
    var presenter = ProfilePresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.presenter.getAllUploadedFilesForUser()
    }

    //MARK: - Helper Methods
    func setData() {
        self.cstHeightStackView.constant = 0 //or 80 if other profile view
        self.progressView.isHidden = true
        self.progressView.startAngle = -90
        self.progressView.style = .ontop
        self.progressView.startProgress(to: 95, duration: 0.1)
        
        self.labelName.text = APP_MANAGER.session?.value(forKey: DBColumn.nick) as? String ?? ""
        self.labelDistance.text = "0 km away"
        self.labelDistance.isHidden = true
        self.labelMatchPercentage.text = "95%"
        
        let userProfileData = self.presenter.getUserQuestionAndAnswer(data: self.dataUserSavedQuestions)
        self.labelAge.text = "\(userProfileData.age.shortQuestionTitle): \(userProfileData.age.optionSelected)"
        self.labelHeight.text = "\(userProfileData.height.shortQuestionTitle): \(userProfileData.height.optionSelected)"
        self.labelNationality.text = "\(userProfileData.nationality.shortQuestionTitle): \(userProfileData.nationality.optionSelected)"
        self.labelLookingFor.text = "\(userProfileData.lookingFor.shortQuestionTitle): \(userProfileData.lookingFor.optionSelected)"
        self.labelAboutMe.text = userProfileData.aboutMe
        
        //set photos
        switch self.dataUserPhotosVideo.count {
        case 1:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            break
        case 2:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[1].uploadFileUrl ?? "", imageView: self.imageViewProfile2, placeholderImage: UIImage(named: "default_placeholder"))
            break
        case 3:
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[0].uploadFileUrl ?? "", imageView: self.imageViewProfile1, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[1].uploadFileUrl ?? "", imageView: self.imageViewProfile2, placeholderImage: UIImage(named: "default_placeholder"))
            self.setImageWithUrl(imageUrl: self.dataUserPhotosVideo[2].uploadFileUrl ?? "", imageView: self.imageViewProfile3, placeholderImage: UIImage(named: "default_placeholder"))
            break
        default:
            break
        }
    }
    
    //MARK: - Button Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func maybeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func crushButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
    }
    
    @IBAction func editProfileButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func editMultimediaButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(UploadPhotoVideoVC(data: self.mainDataUserPhotosVideo), animated: true)
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
            self.imageViewVideo.image = self.getVideoThumbnailImage(fileUrl: userVideo[0].uploadFileUrl!)
            self.imageViewVideo.image = UIImage(named: "man")
            self.presenter.getUserSavedQuestions()
        }
    }
    
    func profile(isSuccess: Bool, userSavedQuestions: [PFObject], msg: String) {
        if isSuccess {
            self.dataUserSavedQuestions = userSavedQuestions
            self.setData()
        } else {
            self.showToast(message: msg)
        }
    }
}
