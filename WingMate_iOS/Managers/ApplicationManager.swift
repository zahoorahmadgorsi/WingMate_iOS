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
    var session : PFUser? {
        set {
            _session = newValue
            if _session == nil {
                UserDefaults.standard.removeObject(forKey: kSESSION_KEY);
                return;
            }
            
            var user = User()
            user.objectId = newValue?.value(forKey: DatabaseColumn.objectId) as? String ?? ""
            user.gender = newValue?.value(forKey: DatabaseColumn.gender) as? String ?? "male"
            user.nick = newValue?.value(forKey: DatabaseColumn.nick) as? String ?? ""
            user.emailVerified = newValue?.value(forKey: DatabaseColumn.emailVerified) as? Bool ?? false
            user.username = newValue?.value(forKey: DatabaseColumn.username) as? String ?? ""
            user.email = newValue?.value(forKey: DatabaseColumn.email) as? String ?? ""
            user.isPaidUser = newValue?.value(forKey: DatabaseColumn.isPaidUser) as? Bool ?? false
            user.isMandatoryQuestionnairesFilled = newValue?.value(forKey: DatabaseColumn.isMandatoryQuestionnairesFilled) as? Bool ?? false
            user.isOptionalQuestionnairesFilled = newValue?.value(forKey: DatabaseColumn.isOptionalQuestionnairesFilled) as? Bool ?? false
         
            UserDefaults.standard.set(try! PropertyListEncoder().encode(user), forKey:kSESSION_KEY)
            UserDefaults.standard.synchronize();
        }
        
        get {
            _session = nil;
            var user = User()
            if let data = UserDefaults.standard.value(forKey: kSESSION_KEY) as? Data {
                user = try! PropertyListDecoder().decode(User.self, from: data)
                _session = PFUser()
                _session?.setValue(user.objectId, forKey: DatabaseColumn.objectId)
                _session?.setValue(user.gender, forKey: DatabaseColumn.gender)
                _session?.setValue(user.nick, forKey: DatabaseColumn.nick)
                _session?.setValue(user.emailVerified, forKey: DatabaseColumn.emailVerified)
                _session?.setValue(user.username, forKey: DatabaseColumn.username)
                _session?.setValue(user.email, forKey: DatabaseColumn.email)
                _session?.setValue(user.isPaidUser, forKey: DatabaseColumn.isPaidUser)
                _session?.setValue(user.isMandatoryQuestionnairesFilled, forKey: DatabaseColumn.isMandatoryQuestionnairesFilled)
                _session?.setValue(user.isOptionalQuestionnairesFilled, forKey: DatabaseColumn.isOptionalQuestionnairesFilled)
            }
            return _session;
            
        }
    }
    
    //Login status
    let kIsLoggedInKey = "kIsLoggedInKey"
    var isLoggedIn : Bool? {
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
    
    //Email key
    let kEmailKey = "kEmailKey"
    var userEmail: String? {
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: kEmailKey)
                return
            }
            UserDefaults.standard.set(newValue, forKey: kEmailKey)
        }
        get {
            
            if let password = UserDefaults.standard.value(forKey: kEmailKey) {
                return password as? String
            }
            return ""
        }
    }
    
    //Password key
    let kPasswordKey = "kPasswordKey"
    var userPassword: String? {
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: kPasswordKey)
                return
            }
            UserDefaults.standard.set(newValue, forKey: kPasswordKey)
        }
        get {
            if let password = UserDefaults.standard.value(forKey: kPasswordKey) {
                return password as? String
            }
            return ""
        }
    }
    
}

