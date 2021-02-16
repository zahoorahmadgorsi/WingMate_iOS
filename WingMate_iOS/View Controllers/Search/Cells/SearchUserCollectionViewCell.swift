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
            self.labelName.text = data?.value(forKey: "nick") as? String
            let userLocation = data?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            
            if let myLocation = APP_DELEGATE.currentLocation {
                if userLocation == PFGeoPoint(latitude: 0, longitude: 0) {
                    self.labelLocation.text = "N/A"
                } else {
                    let myGeoPoint = PFGeoPoint(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
                    let userGeoPoint = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    let distance = myGeoPoint.distanceInKilometers(to: userGeoPoint)
                    self.labelLocation.text = "\(distance.rounded(toPlaces: 1)) KM"
                }
            } else {
                self.labelLocation.text = "N/A"
            }
        }
    }

}

