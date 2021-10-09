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
        let center  = UNUserNotificationCenter.current()
            center.delegate = self
        UserDefaults.standard.setValue(Date(), forKey: UserDefaultKeys.latestDateTime)
        self.configureParse()
        self.configurePushNotifications(application: application)
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
extension AppDelegate: UNUserNotificationCenterDelegate {
    func configurePushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .carPlay ]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
            
            UNUserNotificationCenter.current().delegate = self // For iOS 10 display notification (sent via APNS) for when app in foreground
            
//            application.registerForRemoteNotifications()
        }
        
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let request = response.notification.request
        let userInfo = request.content.userInfo
       // print("payload data: \(userInfo)\n")
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            return
          }
        if let message = aps["alert"] {
            print("payload message: \(message)")
            coordinateToSomeVC()
        }
        
        completionHandler()
    }
    private func coordinateToSomeVC()
    {
        guard let window = UIApplication.shared.keyWindow else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let yourVC = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! UITabBarController
        yourVC.selectedIndex = 3
        //let navController = UINavigationController(rootViewController: yourVC)
        //navController.modalPresentationStyle = .fullScreen

        // you can assign your vc directly or push it in navigation stack as follows:
        window.rootViewController = yourVC
        window.makeKeyAndVisible()
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("mb: Presented")
        NotificationCenter.default.post(name: Notification.Name("refreshUserObject"), object: nil)
        completionHandler([.alert, .badge, .sound])
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
    
    //receive notification
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
    }
    
}
