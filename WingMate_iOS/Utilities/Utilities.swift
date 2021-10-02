//
//  APIKey.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation
import UIKit
import NotificationBannerSwift
import Parse

class Utilities {
    
    static let shared = Utilities()
    private init() {}
    
    func getDeviceType() -> (String, DeviceType) {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return ("iPhone", DeviceType.iPhone5)
            case 1334:
                return ("iPhone", DeviceType.iPhone6)
            case 1920, 2208:
                return ("iPhone", DeviceType.iPhone6Plus)
            case 2436:
                return ("iPhone", DeviceType.iPhoneX)
            case 2688:
                return ("iPhone", DeviceType.iPhoneXSMax)
            case 1792:
                return ("iPhone", DeviceType.iPhoneXR)
            default:
                return ("iPhone", DeviceType.none)
            }
        } else if UIDevice().userInterfaceIdiom == .pad {
            return ("iPad", DeviceType.none)
        } else {
            return ("iPad", DeviceType.none)
        }
    }
    
    func getViewController(identifier: String, storyboardType: StoryboardType) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    func format(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        
        if duration >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        
        return formatter.string(from: duration) ?? ""
    }
    
    //MARK: - Growing Notification Banner
    func showErrorBanner(title: String? = "\nError", msg: String) {
        var banner = GrowingNotificationBanner()
        banner.dismiss()
        banner = GrowingNotificationBanner(title: title, subtitle: msg, style: .danger)
        banner.haptic = .heavy
        banner.show()
    }
    
    func showSuccessBanner(title: String? = "\nSuccess", msg: String) {
        var banner = GrowingNotificationBanner()
        banner.dismiss()
        banner = GrowingNotificationBanner(title: title, subtitle: msg, style: .success)
        banner.haptic = .heavy
        banner.show()
    }
    
    func getDistance(userLocation: PFGeoPoint) -> String {
        var distanceString = "N/A"
        if let myLocation = APP_DELEGATE.currentLocation {
            if userLocation == PFGeoPoint(latitude: 0, longitude: 0) {
                distanceString = "N/A"
            } else {
                let myGeoPoint = PFGeoPoint(latitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude)
                let userGeoPoint = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                let distance = myGeoPoint.distanceInKilometers(to: userGeoPoint)
                distanceString = "\(distance.rounded(toPlaces: 1)) KM"
            }
        } else {
            distanceString = "N/A"
        }
        return distanceString
    }
}

// ------------------------------------------------
// MARK: - FORMAT DATE BY TIME AGO SINCE DATE
// ------------------------------------------------
func timeAgoSinceDate(_ date:Date, currentDate:Date, numericDates:Bool) -> String {
    let calendar = Calendar.current
    let now = currentDate
    let earliest = (now as NSDate).earlierDate(date)
    let latest = (earliest == now) ? date : now
    let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
    
    if (components.year! >= 2) {
        return "\(components.year!) years ago"
    } else if (components.year! >= 1){
        if (numericDates){ return "1 year ago"
        } else { return "Last year" }
    } else if (components.month! >= 2) {
        return "\(components.month!) months ago"
    } else if (components.month! >= 1){
        if (numericDates){ return "1 month ago"
        } else { return "Last month" }
    } else if (components.weekOfYear! >= 2) {
        return "\(components.weekOfYear!) weeks ago"
    } else if (components.weekOfYear! >= 1){
        if (numericDates){ return "1 week ago"
        } else { return "Last week" }
    } else if (components.day! >= 2) {
        return "\(components.day!) days ago"
    } else if (components.day! >= 1){
        if (numericDates){ return "1 day ago"
        } else { return "Yesterday" }
    } else if (components.hour! >= 2) {
        return "\(components.hour!) hours ago"
    } else if (components.hour! >= 1){
        if (numericDates){ return "1 hour ago"
        } else { return "An hour ago" }
    } else if (components.minute! >= 2) {
        return "\(components.minute!) minutes ago"
    } else if (components.minute! >= 1){
        if (numericDates){ return "1 minute ago"
        } else { return "A minute ago" }
    } else if (components.second! >= 3) {
        return "\(components.second!) seconds ago"
    } else { return "Just now" }
}

extension UIViewController {
// ------------------------------------------------
// MARK: - GET PARSE IMAGE - FOR IMAGE VIEW
// ------------------------------------------------
func getParseImage(object:PFObject, colName:String, imageView:UIImageView) {
    let imageFile = object[colName] as? PFFileObject
    imageFile?.getDataInBackground(block: { (imageData, error) in
        if error == nil {
            if let imageData = imageData {
                imageView.image = UIImage(data:imageData)
    }}
        print(error!.localizedDescription)
    })
  }
    
}
