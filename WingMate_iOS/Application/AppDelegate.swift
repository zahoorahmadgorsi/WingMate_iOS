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
import UserNotifications


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var deviceToken: Data?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UserDefaults.standard.setValue(Date(), forKey: UserDefaultKeys.latestDateTime)
        self.configureParse()
        self.configurePushNotifications()
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
            
            self.sendCurrentLocationToServer()
            
            //            #if DEBUG
            //            print("Not hitting location api again and again when in debug mode")
            //            #else
            //                self.sendCurrentLocationToServer()
            //            #endif
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

//MARK: - Push Notifications Configuration
extension AppDelegate {
    func configurePushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.deviceToken = deviceToken
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func createInstallationOnParse(userId: String){
        if let installation = PFInstallation.current(){
            if let token = self.deviceToken {
                installation.setDeviceTokenFrom(token)
                installation.setValue(false, forKey: DBColumn.isAdmin)
                installation.setValue(userId, forKey: DBColumn.userId)
                installation.saveInBackground {
                    (success: Bool, error: Error?) in
                    if (success) {
                        print("You have successfully saved your push installation to Back4App!")
                    } else {
                        if let myError = error{
                            print("Error saving parse installation \(myError.localizedDescription)")
                        }else{
                            print("Uknown error")
                        }
                    }
                }
            }
        }
    }
}
