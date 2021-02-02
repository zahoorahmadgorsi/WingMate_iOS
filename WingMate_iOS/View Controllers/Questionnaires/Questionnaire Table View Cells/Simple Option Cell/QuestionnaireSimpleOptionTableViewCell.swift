//
//  QuestionnaireSimpleOptionTableViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 27/10/2020.
//

import UIKit
import Parse

class QuestionnaireSimpleOptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBgOption: UIView!
    @IBOutlet weak var labelOption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var data: Option? {
        didSet {
            self.labelOption.text = data?.object!.value(forKey: DBColumn.title) as? String ?? ""
            self.viewBgOption.backgroundColor = data?.isSelected ?? false ? UIColor.appThemeRedColor : UIColor.appThemeYellowColor
            self.labelOption.textColor = data?.isSelected ?? false ? UIColor.white : UIColor.appThemePurpleColor
        }
    }
    
//    var isUserSelectedOption = false
//    var dataOption: PFObject? {
//        didSet {
//            self.labelOption.text = dataOption?.value(forKey: DBColumn.title) as? String ?? ""
//            self.viewBgOption.backgroundColor = isUserSelectedOption ? UIColor.appThemeRedColor : UIColor.appThemeYellowColor
//            self.labelOption.textColor = isUserSelectedOption ? UIColor.white : UIColor.appThemePurpleColor
//        }
//    }
    
    
}
