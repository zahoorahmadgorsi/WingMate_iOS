//
//  SearchUserCollectionViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 15/02/2021.
//

import UIKit
import Parse

class SearchUserCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var data: PFUser? {
        didSet {
//            self.setImageWithUrl(imgUrl: data?.fileUrl ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            self.labelName.text = data?.value(forKey: "nick") as? String
        }
    }

}

