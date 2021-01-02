//
//  TermsConditionsCollectionViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 24/12/2020.
//

import UIKit

class TermsConditionsCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var imageViewIsDo: UIImageView!
    @IBOutlet weak var imageViewPlayIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var indexPath: IndexPath!
    var isPhotoMode = true
    var data: PhotoVideoTypeTerms? {
        didSet {
            self.setImageWithUrl(imgUrl: data?.fileUrl ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            self.imageViewIsDo.image = data?.isDo ?? false ? UIImage(named: "big-green-tick") : UIImage(named: "big-red-cross")
            self.imageViewPlayIcon.isHidden = self.isPhotoMode ? true : false
        }
    }
    
}
