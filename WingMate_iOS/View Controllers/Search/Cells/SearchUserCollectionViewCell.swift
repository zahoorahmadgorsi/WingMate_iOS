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
    @IBOutlet weak var labelMatchPercentage: UILabel!
    @IBOutlet weak var imageViewHeart: UIImageView!
    var setPercentageMatchValue: ((Int)-> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var myUserOptions = [PFObject]()
    var data: PFUser? {
        didSet {
            self.imageViewHeart.isHidden = true
            self.setImageWithUrl(imgUrl: data?.value(forKey: DBColumn.profilePic) as? String ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            let ageString = self.getAge(otherUser: data!)
            self.labelName.text = "\(data?.value(forKey: "nick") as? String ?? ""), \(ageString)"
            let userLocation = data?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            self.labelLocation.text = Utilities.shared.getDistance(userLocation: userLocation)
            self.labelMatchPercentage.text = "\(self.getPercentageMatch(myUserOptions: self.myUserOptions, otherUser: data!))% Match"
        }
    }
    
    
    var dataUsers: DashboardData? {
        didSet {
            self.imageViewHeart.isHidden = true
            self.setImageWithUrl(imgUrl: dataUsers?.user?.value(forKey: DBColumn.profilePic) as? String ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            let ageString = self.getAge(otherUser: dataUsers!.user!)
            self.labelName.text = "\(dataUsers?.user?.value(forKey: "nick") as? String ?? ""), \(ageString)"
            let userLocation = data?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            self.labelLocation.text = Utilities.shared.getDistance(userLocation: userLocation)
            let percentage = self.getPercentageMatch(myUserOptions: self.myUserOptions, otherUser: dataUsers!.user!)
            self.labelMatchPercentage.text = "\(percentage)% Match"
            
            DispatchQueue.main.async {
                self.setPercentageMatchValue?(percentage)
            }
        }
    }
    
    var fromUsers: [PFObject]?
    var dataFans: PFObject? {
        didSet {
            let fromUser = dataFans?.value(forKey: DBColumn.fromUser) as? PFUser
            self.setImageWithUrl(imgUrl: fromUser?.value(forKey: DBColumn.profilePic) as? String ?? "", imageView: self.imageViewPhoto, placeholderImage: UIImage(named: "default_placeholder"))
            let ageString = self.getAge(otherUser: fromUser!)
            self.labelName.text = "\(fromUser?.value(forKey: "nick") as? String ?? ""), \(ageString)"
            let userLocation = fromUser?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            self.labelLocation.text = Utilities.shared.getDistance(userLocation: userLocation)
            self.labelMatchPercentage.text = "\(self.getPercentageMatch(myUserOptions: self.myUserOptions, otherUser: fromUser!))% Match"
            for i in self.fromUsers ?? [] {
                let fromUsr = i.value(forKey: DBColumn.fromUser) as? PFUser
                if (fromUsr?.objectId == PFUser.current()?.objectId) && (fromUser?.objectId == PFUser.current()?.objectId) {
                    self.imageViewHeart.isHidden = true
                } else {
                    self.imageViewHeart.isHidden = false
                }
            }
        }
    }

}

