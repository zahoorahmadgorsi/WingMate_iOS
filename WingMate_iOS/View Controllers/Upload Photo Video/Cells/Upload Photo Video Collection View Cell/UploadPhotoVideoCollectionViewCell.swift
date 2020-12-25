//
//  UploadPhotoVideoCollectionViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 22/12/2020.
//

import UIKit

class UploadPhotoVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelStaticTitle: UILabel!
    @IBOutlet weak var labelCross: UILabel!
    @IBOutlet weak var buttonRemove: UIButton!
    @IBOutlet weak var viewAddPhotos: UIView!
    @IBOutlet weak var imageViewPlay: UIImageView!
    var removeImageButtonPressed: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var indexPath: IndexPath!
    var isPhotoMode = true
    var data: UIImage? {
        didSet {
            self.imageViewPhoto.image = data ?? UIImage()
            self.labelStaticTitle.text = self.indexPath.item != 0 ? "" : isPhotoMode ? "Photos" : "Video"
            self.viewAddPhotos.isHidden = data == nil ? false : true
            self.labelCross.isHidden = data == nil ? true : false
            self.buttonRemove.isHidden = data == nil ? true : false
            self.imageViewPlay.isHidden = self.isPhotoMode ? true : data == nil ? true : false
        }
    }
    
    @IBAction func removeImageButtonPressed(_ sender: UIButton) {
        self.removeImageButtonPressed?(sender.tag)
    }
    
}
