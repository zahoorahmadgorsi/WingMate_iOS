//
//  BaseViewController.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import UIKit
import SDWebImage
import AVKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Toast Methods
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
    
    func getVideoThumbnailImage(fileUrl: String) -> UIImage {
        do {
            let asset = AVURLAsset(url: URL(fileURLWithPath: fileUrl), options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
        return UIImage()
    }
    

}
