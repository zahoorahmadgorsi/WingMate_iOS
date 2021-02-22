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
    @IBOutlet weak var labelLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var data: PFUser? {
        didSet {
            self.setImageWithUrl(imgUrl: data?.value(forKey: DBColumn.profilePic) as? String ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            self.labelName.text = "\(data?.value(forKey: "nick") as? String ?? ""), age"
            let userLocation = data?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            self.labelLocation.text = Utilities.shared.getDistance(userLocation: userLocation)
        }
    }
    
    var dataFans: PFObject? {
        didSet {
            let fromUser = dataFans?.value(forKey: DBColumn.fromUser) as? PFUser
            self.setImageWithUrl(imgUrl: fromUser?.value(forKey: DBColumn.profilePic) as? String ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            self.labelName.text = "\(fromUser?.value(forKey: "nick") as? String ?? ""), age"
            let userLocation = fromUser?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            self.labelLocation.text = Utilities.shared.getDistance(userLocation: userLocation)
        }
    }

}

