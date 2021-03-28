//
//  BaseViewController.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import UIKit
import SDWebImage
import AVKit
import SimpleImageViewer
import Parse

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }

    //MARK: - Toast Methods
    func setProfileImage(imageViewProfile: UIImageView) {
        let profileImage = APP_MANAGER.session?.value(forKey: DBColumn.profilePic) as? String ?? ""
        if profileImage == "" {
            imageViewProfile.image = UIImage(named: "default_placeholder")
        } else {
            self.setImageWithUrl(imageUrl: profileImage, imageView: imageViewProfile, placeholderImage: UIImage(named: "default_placeholder"))
        }
    }
    
    func showToast(message : String) {
        let window = UIApplication.shared.keyWindow!
        //        let v = UIView(frame: window.bounds)
        //        window.addSubview(v);
        
        let toastLabel = UILabel(frame: CGRect(x: 20, y: self.view.frame.size.height-100, width: self.view.frame.width - 40, height: 40))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 12)
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.numberOfLines = 2
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        window.addSubview(toastLabel)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            toastLabel.removeFromSuperview()
        }
    }
    
    func popToController(vc: AnyClass) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: vc) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
        
//        if let controllers = self.navigationController?.viewControllers {
//            for i in 0..<controllers.count {
//                if controllers[i].isKind(of: RegisterStepThreeVC.self) {
//                    print("Here: \(i)")
//                }
//            }
//        }
    }
    
    func setImageWithUrl(imageUrl: String, imageView: UIImageView, placeholderImage: UIImage? = nil) {
        imageView.sd_imageIndicator?.startAnimatingIndicator()
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority) { (image, error, sdImageCacheType, url) in
                
            }
        }
    }
    
    func getVideoThumbnail(from url: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 1)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return UIImage()
        }
    }
    
    func playVideo(filePath: String) {
        let player = AVPlayer(url: URL(fileURLWithPath: filePath))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    //MARK: - Image Preview Methods
    func previewImage(imageView: UIImageView) {
        let configuration = ImageViewerConfiguration { config in
            config.imageView = imageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        present(imageViewerController, animated: true)
    }
    
    //MARK: - Calculate Match Percentage
    func getMyUserOptions() -> [PFObject] {
        var myOptions = [PFObject]()
        do {
            let myUserAnswers = try PFUser.current()!.fetchIfNeeded().value(forKey: DBColumn.optionalQuestionAnswersList) as? [PFObject] ?? []
            if myUserAnswers.count > 0 {
                for i in myUserAnswers {
                    let optionsObjArr = try i.fetchIfNeeded().value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
                    myOptions.append(contentsOf: optionsObjArr)
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        return myOptions
    }
    
    func getPercentageMatch(myUserOptions: [PFObject], otherUser: PFUser) -> Int {
        var percentage: Double = 0
        var myOptions = myUserOptions
        var userOptions = [PFObject]()
        
//        do {
//            let myUserAnswers = try PFUser.current()!.fetchIfNeeded().value(forKey: DBColumn.optionalQuestionAnswersList) as? [PFObject] ?? []
//            if myUserAnswers.count > 0 {
//                for i in myUserAnswers {
//                    let optionsObjArr = try i.fetchIfNeeded().value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
//                    myOptions.append(contentsOf: optionsObjArr)
//                }
//            }
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
        
        let otherUserAnswers = otherUser.value(forKey: DBColumn.optionalQuestionAnswersList) as? [PFObject] ?? []
        if otherUserAnswers.count > 0 {
            for i in otherUserAnswers {
                let optionsObjArr = i.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
                userOptions.append(contentsOf: optionsObjArr)
            }
        }
        
        var count = 0
        for i in myOptions {
            for j in userOptions {
                let myOptionObjectId = i.value(forKey: DBColumn.objectId) as? String ?? ""
                let userOptionObjectId = j.value(forKey: DBColumn.objectId) as? String ?? ""
                if myOptionObjectId == userOptionObjectId {
                    count = count + 1
                }
            }
        }
        
        if myOptions.count > 0 {
            let div: Double = Double(count) / Double(myOptions.count)
            percentage = div * 100
        }
        return Int(percentage)
    }
    
}
