//
//  BaseCollectionViewCell.swift
//  Do-ne
//
//  Created by Muneeb on 05/08/2019.
//  Copyright © 2019 Muneeb. All rights reserved.
//


import UIKit

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
}
