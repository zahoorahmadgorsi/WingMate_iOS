//
//  BaseTableViewCell.swift
//  Do-ne
//
//  Created by Muneeb on 05/08/2019.
//  Copyright © 2019 Muneeb. All rights reserved.
//

import SDWebImage
import UIKit

class BaseTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setImageWithUrl(imageUrl: String, imageView: UIImageView, placeholderImage: UIImage? = nil) {
//        imageView.sd_setShowActivityIndicatorView(true)
        if let url = URL(string: imageUrl){
            
//            imageView.sd_setIndicatorStyle(UIActivityIndicatorView.Style.gray)
            imageView.sd_setImage(with: url, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority) { (image, error, sdImageCacheType, url) in
            }
        }
    }
    
}
