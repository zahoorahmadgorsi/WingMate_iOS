//
//  QuestionnaireCountryOptionTableViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 30/10/2020.
//

import UIKit
import Parse

class QuestionnaireCountryOptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBgOption: UIView!
    @IBOutlet weak var labelCountry: UILabel!
    @IBOutlet weak var imageViewCountry: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    var data: Option? {
//        didSet {
//            self.labelCountry.text = data?.title ?? ""
//            self.imageViewCountry.image = UIImage(named: data?.flagImage ?? "")
//            self.viewBgOption.backgroundColor = data?.isSelected ?? false ? UIColor.appThemeRedColor : UIColor.textFieldGrayBackgroundColor
//            self.labelCountry.textColor = data?.isSelected ?? false ? UIColor.white : UIColor.appThemePurpleColor
//        }
//    }
    
    var data: Option? {
        didSet {
            self.labelCountry.text = data?.object!.value(forKey: DatabaseColumn.title) as? String ?? ""
            let thumbnail = self.data?.object?["countryFlagImage"] as? PFFileObject
            thumbnail?.getDataInBackground (block: { (data, error) -> Void in
                if let image = UIImage(data: data!) {
                    self.imageViewCountry.image = image
                }
            })
            self.viewBgOption.backgroundColor = data?.isSelected ?? false ? UIColor.appThemeRedColor : UIColor.appThemeYellowColor
            self.labelCountry.textColor = data?.isSelected ?? false ? UIColor.white : UIColor.appThemePurpleColor
        }
    }
    
}
