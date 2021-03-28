//
//  SliderTableViewCell.swift
//  WingMate_iOS
//
//  Created by mac on 25/03/2021.
//

import UIKit

class SliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sliderRanges: UISlider!
    @IBOutlet weak var labelSelectedRange: UILabel!
    var sliderValueChanged: ((Int)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.labelSelectedRange.text = RangeSelectedString.range1.rawValue + " selected"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sliderAction(_ sender: Any) {
        let val = Int(self.sliderRanges.value)
        switch val {
        case 0:
            self.labelSelectedRange.text = RangeSelectedString.range1.rawValue
            self.sliderValueChanged?(RangeMeters.range1.rawValue)
            break
        case 1:
            self.labelSelectedRange.text = RangeSelectedString.range2.rawValue
            self.sliderValueChanged?(RangeMeters.range2.rawValue)
            break
        case 2:
            self.labelSelectedRange.text = RangeSelectedString.range3.rawValue
            self.sliderValueChanged?(RangeMeters.range3.rawValue)
            break
        case 3:
            self.labelSelectedRange.text = RangeSelectedString.range4.rawValue
            self.sliderValueChanged?(RangeMeters.range4.rawValue)
            break
        case 4:
            self.labelSelectedRange.text = RangeSelectedString.range5.rawValue
            self.sliderValueChanged?(RangeMeters.range5.rawValue)
            break
        case 5:
            self.labelSelectedRange.text = RangeSelectedString.range6.rawValue
            self.sliderValueChanged?(RangeMeters.range6.rawValue)
            break
        case 6:
            self.labelSelectedRange.text = RangeSelectedString.range7.rawValue
            self.sliderValueChanged?(RangeMeters.range7.rawValue)
            break
        case 7:
            self.labelSelectedRange.text = RangeSelectedString.range8.rawValue
            self.sliderValueChanged?(RangeMeters.range8.rawValue)
            break
        case 8:
            self.labelSelectedRange.text = RangeSelectedString.range9.rawValue
            self.sliderValueChanged?(RangeMeters.range9.rawValue)
            break
        case 9:
            self.labelSelectedRange.text = RangeSelectedString.range10.rawValue
            self.sliderValueChanged?(RangeMeters.range10.rawValue)
            break
        case 10:
            self.labelSelectedRange.text = RangeSelectedString.range11.rawValue
            self.sliderValueChanged?(RangeMeters.range11.rawValue)
            break
        default:
            break
        }
        
        self.labelSelectedRange.text = self.labelSelectedRange.text! + " selected"
    }
    
}

enum RangeSelectedString: String {
    case range1 = "5m"
    case range2 = "10m"
    case range3 = "50m"
    case range4 = "100m"
    case range5 = "250m"
    case range6 = "1km"
    case range7 = "5km"
    case range8 = "10km"
    case range9 = "100km"
    case range10 = "1000km"
    case range11 = "5000km"
}

enum RangeMeters: Int {
    case range1 = 5
    case range2 = 10
    case range3 = 50
    case range4 = 100
    case range5 = 250
    case range6 = 1000
    case range7 = 5000
    case range8 = 10_000
    case range9 = 100_000
    case range10 = 10_00000
    case range11 = 50_00000
}
