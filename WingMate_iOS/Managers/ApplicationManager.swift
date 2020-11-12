//
//  ApplicationManager.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation
import UIKit
import Parse

class ApplicationManager: NSObject {
    
    static let shared = ApplicationManager()
    var appVersion : String {
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return versionNumber ?? "";
    }
    
    var UDID : String
    {
        #if targetEnvironment(simulator)
        // Simulator
        return "IOS_Simulator1"
        #else
        return (UIDevice.current.identifierForVendor?.uuidString ?? "UNIQUE_UDID")
        #endif
        
    }
    
    
    //MARK: -Methods
    
    
    //MARK: - User Defaults
    let kSESSION_KEY = "kSessionKey"
    private var _session : PFUser?
    var session : PFUser?
    {
        set {
            _session = newValue
            if _session == nil
            {
                UserDefaults.standard.removeObject(forKey: kSESSION_KEY);
                return;
            }
            
            
            
            UserDefaults.standard.setValue(session, forKey: kSESSION_KEY)
        }
        
        get {
            _session = nil;
            if let data = UserDefaults.standard.value(forKey: kSESSION_KEY) as? PFUser {
                _session = data
            }
            return _session
            
        }
    }
    //Login status
    let kIsLoggedInKey = "kIsLoggedInKey"
    var isLoggedIn : Bool?
    {
        set {
            UserDefaults.standard.setValue(newValue, forKey: kIsLoggedInKey)
        }
        get {
            if let value = UserDefaults.standard.value(forKey: kIsLoggedInKey) as? Bool {
                return value
            }
            return false
        }
    }
}

