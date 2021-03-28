//
//  EditProfileUserQuestionTableViewCell.swift
//  WingMate_iOS
//
//  Created by Muneeb on 19/01/2021.
//

import UIKit
import Parse

class EditProfileUserQuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var labelUserOption: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var data: UserProfileQuestion? {
        didSet {
            self.labelQuestion.text = data?.questionObject?.value(forKey: DBColumn.shortTitle) as? String ?? ""
            var selectedOptions = ""
            if let userAnswer = data?.userAnswerObject {
                let options = userAnswer.value(forKey: DBColumn.optionsObjArray) as? [PFObject] ?? []
                for (i, item) in options.enumerated() {
                    let opt = item.value(forKey: DBColumn.title) as? String ?? ""
                    if i == options.count - 1 {
                        selectedOptions = selectedOptions + opt
                    } else {
                        selectedOptions = selectedOptions  + opt + ", "
                    }
                }
            }
            self.labelUserOption.text = selectedOptions
        }
    }
    
    
}
