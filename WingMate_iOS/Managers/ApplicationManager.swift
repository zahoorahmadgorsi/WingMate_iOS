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
    var countryQuestionId = "C5dYcH5GNx"
    
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
            user.objectId = newValue?.value(forKey: DBColumn.objectId) as? String ?? ""
            user.gender = newValue?.value(forKey: DBColumn.gender) as? String ?? "male"
            user.nick = newValue?.value(forKey: DBColumn.nick) as? String ?? ""
            user.emailVerified = newValue?.value(forKey: DBColumn.emailVerified) as? Bool ?? false
            user.username = newValue?.value(forKey: DBColumn.username) as? String ?? ""
            user.email = newValue?.value(forKey: DBColumn.email) as? String ?? ""
            user.isPaidUser = newValue?.value(forKey: DBColumn.isPaidUser) as? Bool ?? false
            user.isMandatoryQuestionnairesFilled = newValue?.value(forKey: DBColumn.isMandatoryQuestionnairesFilled) as? Bool ?? false
            user.isOptionalQuestionnairesFilled = newValue?.value(forKey: DBColumn.isOptionalQuestionnairesFilled) as? Bool ?? false
            user.aboutMe = newValue?.value(forKey: DBColumn.aboutMe) as? String ?? ""
            user.profilePic = newValue?.value(forKey: DBColumn.profilePic) as? String ?? ""
            let currentLocation = newValue?.value(forKey: DBColumn.currentLocation) as? PFGeoPoint ?? PFGeoPoint()
            user.currentLocationLat = currentLocation.latitude
            user.currentLocationLng = currentLocation.longitude
         
            UserDefaults.standard.set(try! PropertyListEncoder().encode(user), forKey:kSESSION_KEY)
            UserDefaults.standard.synchronize();
        }
        
        get {
            _session = nil;
            var user = User()
            if let data = UserDefaults.standard.value(forKey: kSESSION_KEY) as? Data {
                user = try! PropertyListDecoder().decode(User.self, from: data)
                _session = PFUser()
                _session?.setValue(user.objectId ?? "", forKey: DBColumn.objectId)
                _session?.setValue(user.gender ?? "Male", forKey: DBColumn.gender)
                _session?.setValue(user.nick ?? "", forKey: DBColumn.nick)
                _session?.setValue(user.emailVerified ?? false, forKey: DBColumn.emailVerified)
                _session?.setValue(user.username ?? "", forKey: DBColumn.username)
                _session?.setValue(user.email ?? "", forKey: DBColumn.email)
                _session?.setValue(user.isPaidUser ?? false, forKey: DBColumn.isPaidUser)
                _session?.setValue(user.isMandatoryQuestionnairesFilled ?? false, forKey: DBColumn.isMandatoryQuestionnairesFilled)
                _session?.setValue(user.isOptionalQuestionnairesFilled ?? false, forKey: DBColumn.isOptionalQuestionnairesFilled)
                _session?.setValue(user.aboutMe ?? "", forKey: DBColumn.aboutMe)
                _session?.setValue(user.profilePic ?? "", forKey: DBColumn.profilePic)
                _session?.setValue(PFGeoPoint(latitude: user.currentLocationLat ?? 0, longitude: user.currentLocationLng ?? 0), forKey: DBColumn.currentLocation)
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

