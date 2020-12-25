//
//  TermsConditionsCollectionViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 24/12/2020.
//

import UIKit

class TermsConditionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var imageViewIsDo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var indexPath: IndexPath!
    var data: UIImage? {
        didSet {
            self.imageViewPhoto.image = data ?? UIImage()
            self.imageViewIsDo.image = UIImage(named: "big-green-tick") //big-red-cross
        }
    }
    
}
