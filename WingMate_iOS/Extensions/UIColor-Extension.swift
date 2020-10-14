//
//  UIColor-Extension.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation
import UIKit

extension UIColor {
    static var appThemeColor: UIColor {
        return UIColor(named: "AppThemeColor") ?? .black
    }
    
    static var buttonColor: UIColor {
        return UIColor(named: "ButtonColor") ?? .white
    }
    
    static var gradientStartColor: UIColor {
        return UIColor(red:84/255, green:130/255 ,blue:120/255 , alpha:1)
    }
    
    static var gradientEndColor: UIColor {
        return UIColor(red:42/255, green:127/255 ,blue:153/255 , alpha:1)
    }
    
    static var lightGrayBorderColor: UIColor {
        return UIColor(red:215/255, green:215/255 ,blue:215/255 , alpha:1)
    }
    
    static var grayTextColor: UIColor {
        return UIColor(red:82/255, green:82/255 ,blue:82/255 , alpha:1)
    }
    
    static var appThemeGreenColor: UIColor {
        return UIColor(red:42/255, green:127/255 ,blue:153/255 , alpha:1)
    }
    
    static var calendarDisableGrayColor: UIColor {
        return UIColor(red:180/255, green:180/255 ,blue:180/255 , alpha:1)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
}


extension UIColor {
    
    static let app_tab_bar_selected_color = UIColor.colorWithHex("91AAB4")
    
    class func colorWithHex (_ hex:String?) -> UIColor {
        
        if hex == nil {
            return UIColor.black;
        }
        var cString:String = hex!.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString = cString.substring(from: cString.index(cString.startIndex, offsetBy: 1))
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}
