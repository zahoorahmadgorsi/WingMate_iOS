//
//  User.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/10/2020.

import Foundation
import Parse

struct User : Codable {
    var objectId : String?
    var gender : String?
    var nick : String?
    var emailVerified : Bool?
    var username : String?
    var email : String?
    var isPaidUser : Bool?
    var isMandatoryQuestionnairesFilled : Bool?
    var isOptionalQuestionnairesFilled : Bool?
    var aboutMe : String?
    var profilePic : String?
    var currentLocationLat : CLLocationDegrees?
    var currentLocationLng : CLLocationDegrees?
//    var mandatoryQuestionAnswersList : [PFObject]?
//    var optionalQuestionAnswersList : [PFObject]?
    
    init(){
        self.objectId = ""
        self.gender = "Male"
        self.nick = ""
        self.emailVerified = false
        self.username = ""
        self.email = ""
        self.isPaidUser = false
        self.isMandatoryQuestionnairesFilled = false
        self.isOptionalQuestionnairesFilled = false
        self.aboutMe = ""
        self.profilePic = ""
        self.currentLocationLat = 0
        self.currentLocationLng = 0
//        self.mandatoryQuestionAnswersList = [PFObject]()
//        self.optionalQuestionAnswersList = [PFObject]()
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "objectId"
        case gender = "gender"
        case nick = "nick"
        case emailVerified = "emailVerified"
        case username = "username"
        case email = "email"
        case isPaidUser = "isPaidUser"
        case isMandatoryQuestionnairesFilled = "isMandatoryQuestionnairesFilled"
        case isOptionalQuestionnairesFilled = "isOptionalQuestionnairesFilled"
        case aboutMe = "aboutMe"
        case profilePic = "profilePic"
        case currentLocationLat = "currentLocationLat"
        case currentLocationLng = "currentLocationLng"
//        case mandatoryQuestionAnswersList = "mandatoryQuestionAnswersList"
//        case optionalQuestionAnswersList = "optionalQuestionAnswersList"
    }

}
