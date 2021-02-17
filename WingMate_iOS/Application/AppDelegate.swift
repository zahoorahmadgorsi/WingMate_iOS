//
//  AppDelegate.swift
//  WingMate_iOS
//
//  Created by iMac on 10/10/2020.
//

import UIKit
import IQKeyboardManager
import SVProgressHUD
import Parse
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.configureParse()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = SplashVC()
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        IQKeyboardManager.shared().isEnabled = true
        self.setSVProgressHUD()
        self.getCurrentLocation()
        return true
    }
    
    func setSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultAnimationType(.native)
    }
    
    func configureParse() {
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = kApplicationId
            $0.clientKey = kClientKey
            $0.server = kServer
        }
        Parse.initialize(with: parseConfig)

    }
    
    //MARK: - Decide RootViewController
    func decideRootViewController() {
    }
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    //MARK: - Current Location
    func getCurrentLocation() {
        self.locationManager = CLLocationManager()
        if locationManager != nil {
            locationManager!.delegate = self;
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.startUpdatingLocation()
            locationManager!.startMonitoringSignificantLocationChanges()
            locationManager!.distanceFilter = 500
            locationManager!.allowsBackgroundLocationUpdates = true
            locationManager!.pausesLocationUpdatesAutomatically = false
            locationManager!.activityType = .automotiveNavigation
            locationManager!.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let loc = locations.last {
            print(loc)
            self.currentLocation = loc
//            self.sendCurrentLocationToServer()
        }
    }
    
    func sendCurrentLocationToServer() {
        if let currentLoc = APP_DELEGATE.locationManager?.location {
            let geoPoint = PFGeoPoint(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
            PFUser.current()?.setValue(geoPoint, forKey: DBColumn.currentLocation)
            ParseAPIManager.updateUserObject() { (success) in
                if success {
                    APP_MANAGER.session = PFUser.current()
                } else {
                }
            } onFailure: { (error) in
                print(error)
            }
        }
    }
}
