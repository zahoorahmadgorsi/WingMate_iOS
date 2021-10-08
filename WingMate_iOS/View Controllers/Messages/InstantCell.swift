//
//  InstantCell.swift
//  WingMate_iOS
//
//  Created by Anish on 9/26/21.
//

import UIKit

class InstantCell: UITableViewCell {

    /*--- VIEWS ---*/
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLbl : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Layouts
      //  avatarImg.layer.cornerRadius = avatarImg.bounds.size.width/2
        
        usernameLabel.autoresizingMask = .flexibleWidth
        lastMessageLabel.autoresizingMask = .flexibleWidth
        
    }

}
