//
//  TermsConditionsTableViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 24/12/2020.
//

import UIKit

class TermsConditionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewIsDo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var data: TextTypeTerms? {
        didSet {
            self.labelTitle.text = data?.title ?? ""
            self.imageViewIsDo.image = data?.isDo ?? false ? UIImage(named: "small-green-tick") : UIImage(named: "small-red-cross")
        }
    }
    
}
