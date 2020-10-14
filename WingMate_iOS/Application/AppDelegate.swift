//
//  AppDelegate.swift
//  WingMate_iOS
//
//  Created by iMac on 10/10/2020.
//

import UIKit
import Parse

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = kApplicationId
            $0.clientKey = kClientKey
            $0.server = kServer
        }
        
        return true
    }

}

