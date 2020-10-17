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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.configureParse()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = SplashVC()
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        IQKeyboardManager.shared().isEnabled = true
        self.setSVProgressHUD()
        return true
    }
    
    func setSVProgressHUD() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setDefaultAnimationType(.native)
    }
    
    func configureParse() {
        _ = ParseClientConfiguration {
            $0.applicationId = kApplicationId
            $0.clientKey = kClientKey
            $0.server = kServer
        }
    }
    
    //MARK: - Decide RootViewController
    func decideRootViewController() {
        //        let mainTabBarVC = Utilities.shared.getViewController(identifier: MainTabVC.className , storyboardType: .main)
        //        self.window?.rootViewController = APP_MANAGER.isLoggedIn ?? false ? mainTabBarVC : LoginVC()
        //        self.window?.makeKeyAndVisible()
        //        if APP_MANAGER.isLoggedIn ?? false {
        //            API_TOKEN = APP_MANAGER.session?.access_token ?? ""
        
        
        
    }
    
}
