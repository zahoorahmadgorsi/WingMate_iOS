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


