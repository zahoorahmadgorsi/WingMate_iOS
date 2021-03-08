//
//  BaseCollectionViewCell.swift
//  Do-ne
//
//  Created by Muneeb on 05/08/2019.
//  Copyright © 2019 Muneeb. All rights reserved.
//


import UIKit
import AVKit
import Parse

class BaseCollectionViewCell: UICollectionViewCell {
    
    func setImageWithUrl(imgUrl: String, imageView:UIImageView, placeholderImage: UIImage? = nil) {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        actInd.center =     imageView.center
        actInd.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            actInd.style =
                UIActivityIndicatorView.Style.large
        } else {
            actInd.style =
            .whiteLarge //UIActivityIndicatorView.Style.large
        }
        actInd.color = UIColor.red;
        //-- imageView.addSubview(actInd)
        actInd.startAnimating()
        let url = URL(string: imgUrl)
        
        imageView.sd_setImage(with: url, placeholderImage: placeholderImage) { (image, error, sdImageCacheType, url) in
            actInd.removeFromSuperview()
        }
        
    }
    
    func getVideoThumbnail(from url: String) -> UIImage? {
        let asset = AVAsset(url: URL(string: url)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            print("THUMBNAIL GENERATED")
            return thumbnail
        } catch {
            return UIImage()
        }
    }
    
    //MARK: - Calculate Match Percentage
    func getPercentageMatch(myUserOptions: [PFObject], otherUser: PFUser) -> Int {
        var percentage: Double = 0
        var myOptions = myUserOptions
        var userOptions = [PFObject]()
        
//        do {
//            let myUserAnswers = try currentUser.fetchIfNeeded().value(forKey: DBColumn.optionalQuestionAnswersList) as? [PFObject] ?? []
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
    
    func getAge(otherUser: PFUser) -> String {
        var ageString = ""
        var userOptions = [PFObject]()
        let otherUserAnswers = otherUser.value(forKey: DBColumn.mandatoryQuestionAnswersList) as? [PFObject] ?? []
        if otherUserAnswers.count > 0 {
            for i in otherUserAnswers {
                let optionsObjArr = i.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
                userOptions.append(contentsOf: optionsObjArr)
            }
            
            for i in userOptions {
                let userOptionQuestionObj = i.value(forKey: DBColumn.questionId) as? PFObject
                let questionId = userOptionQuestionObj!.value(forKey: DBColumn.objectId) as? String ?? ""
                if questionId == Constants.ageQuestionId {
                    ageString = i.value(forKey: DBColumn.title) as? String ?? ""
                }
            }
        }
        return ageString
    }
}
