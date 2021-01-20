//
//  MyProfileTableViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 16/01/2021.
//

import UIKit
import Parse

class MyProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelItem: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var data: PFObject? {
        didSet {
            if let dataQstn = data {
                let questionObj = dataQstn.value(forKey: DBColumn.questionId) as! PFObject
                let questionShortTitle = questionObj.value(forKey: DBColumn.shortTitle) as? String ?? ""
                let userSelectedOptionsObj = dataQstn.value(forKey: DBColumn.optionsObjArray) as? Array<PFObject> ?? []
                
                var selectedAnswer = ""
                for (i, item) in userSelectedOptionsObj.enumerated() {
                    if i == userSelectedOptionsObj.count - 1 {
                        selectedAnswer += item.value(forKey: DBColumn.title) as? String ?? ""
                    } else {
                        selectedAnswer += (item.value(forKey: DBColumn.title) as? String ?? "") + ", "
                    }
                }
                let stringToDisplay = questionShortTitle + ": " + selectedAnswer
                
                self.labelItem.attributedText = self.attributedText(withString: stringToDisplay, boldString: questionShortTitle, font: UIFont(name: "OpenSans-Regular", size: 14)!)
            }
        }
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    
}
