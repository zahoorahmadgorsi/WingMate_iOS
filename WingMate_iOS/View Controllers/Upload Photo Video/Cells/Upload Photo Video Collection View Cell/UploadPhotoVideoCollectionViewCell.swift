//
//  UploadPhotoVideoCollectionViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 22/12/2020.
//

import UIKit

class UploadPhotoVideoCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelStaticTitle: UILabel!
    @IBOutlet weak var labelCross: UILabel!
    @IBOutlet weak var buttonRemove: UIButton!
    @IBOutlet weak var viewAddPhotos: UIView!
    @IBOutlet weak var imageViewPlay: UIImageView!
    var removeImageButtonPressed: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var indexPath: IndexPath!
    var isPhotoMode = true
    var data: UserPhotoVideoModel? {
        didSet {
            if self.isPhotoMode {
                if data?.uploadFileUrl != nil {
                    self.setImageWithUrl(imgUrl: data?.uploadFileUrl ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
                } else {
                    self.imageViewPhoto.image = UIImage()
                }
            } else {
                if data?.uploadFileUrl != nil {
                    self.imageViewPhoto.image = self.getVideoThumbnail(from: data?.uploadFileUrl ?? "")
                } else {
                    self.imageViewPhoto.image = UIImage()
                }
            }
            self.labelStaticTitle.text = self.indexPath.item != 0 ? "" : isPhotoMode ? "Photos" : "Video"
            self.viewAddPhotos.isHidden = data?.uploadFileUrl == nil ? false : true
            self.labelCross.isHidden = data?.uploadFileUrl == nil ? true : false
            self.buttonRemove.isHidden = data?.uploadFileUrl == nil ? true : false
            self.imageViewPlay.isHidden = self.isPhotoMode ? true : data?.uploadFileUrl == nil ? true : false
        }
    }
    
    @IBAction func removeImageButtonPressed(_ sender: UIButton) {
        self.removeImageButtonPressed?(sender.tag)
    }
    
}
