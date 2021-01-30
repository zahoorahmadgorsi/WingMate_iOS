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

class ProfileVC: BaseViewController {
    
    //MARK: - Outlets & Constraints
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var imageViewProfile1: UIImageView!
    @IBOutlet weak var imageViewProfile2: UIImageView!
    @IBOutlet weak var imageViewProfile3: UIImageView!
    @IBOutlet weak var imageViewVideo: UIImageView!
    @IBOutlet weak var labelAboutMe: UILabel!
    @IBOutlet weak var cstHeightStackView: NSLayoutConstraint!
    @IBOutlet weak var stackViewMyProfileButtons: UIStackView!
    @IBOutlet weak var stackViewOthersProfileButtons: UIStackView!
    @IBOutlet weak var tableViewUserQuestions: UITableView!
    @IBOutlet weak var cstHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var progressView: UICircularProgressRing!
    @IBOutlet weak var labelMatchPercentage: UILabel!
    var mainDataUserPhotosVideo = [UserPhotoVideoModel]()
    var dataUserPhotosVideo = [UserPhotoVideoModel]()
    var dataUserSavedQuestions = [PFObject]()
    var presenter = ProfilePresenter()
    var videoUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.attach(vc: self)
        self.registerTableViewCells()
        self.presenter.getAllUploadedFilesForUser()
        self.presenter.getUserSavedQuestions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    //MARK: - Helper Methods
    func registerTableViewCells() {
        self.tableViewUserQuestions.register(UINib(nibName: MyProfileTableViewCell.className, bundle: nil), forCellReuseIdentifier: MyProfileTableViewCell.className)
    }
    
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
        
        self.tableViewUserQuestions.reloadData {
            self.cstHeightTableView.constant = self.tableViewUserQuestions.contentSize.height
            self.tableViewUserQuestions.layoutIfNeeded()
            self.cstHeightTableView.constant = self.tableViewUserQuestions.contentSize.height
        }
        
        let aboutMeText = APP_MANAGER.session?.value(forKey: DBColumn.aboutMe) as? String ?? ""
        let stringToDisplay = aboutMeText == "" ? "" : "About Me: \(aboutMeText)"
        self.labelAboutMe.attributedText = self.attributedText(withString: stringToDisplay, boldString: "About Me:", font: UIFont(name: "OpenSans-Regular", size: 14)!)
        
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
        let vc = EditProfileVC(userSavedOptions: self.dataUserSavedQuestions)
        vc.isAnyInfoUpdated = { [weak self] status in
            if status {
                self?.presenter.getUserSavedQuestions()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func editMultimediaButtonPressed(_ sender: Any) {
        self.navigationController?.pushViewController(UploadPhotoVideoVC(data: self.mainDataUserPhotosVideo), animated: true)
    }
    
    @IBAction func videoButtonPressed(_ sender: Any) {
        self.playVideo(filePath: self.videoUrl)
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
            self.videoUrl = userVideo[0].uploadFileUrl!
            
            if let img = self.getVideoThumbnail(from: self.videoUrl) {
                self.imageViewVideo.image = img
            }
            
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
