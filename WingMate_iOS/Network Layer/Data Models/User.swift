//
//  User.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/10/2020.

import Foundation

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
    
    init(){
        self.objectId = ""
        self.gender = "male"
        self.nick = ""
        self.emailVerified = false
        self.username = ""
        self.email = ""
        self.isPaidUser = false
        self.isMandatoryQuestionnairesFilled = false
        self.isOptionalQuestionnairesFilled = false

    }
    
//    init(objectId: String, email: String, emailVerified: Bool, gender: String, nick: String, isPaidUser: Bool, isMandatoryQuestionnairesFilled: Bool, isOptionalQuestionnairesFilled: Bool) {
//        self.objectId = objectId
//        self.email = email
//        self.emailVerified = emailVerified
//        self.gender = gender
//        self.nick = nick
//        self.isPaidUser = isPaidUser
//        self.isMandatoryQuestionnairesFilled = isMandatoryQuestionnairesFilled
//        self.isOptionalQuestionnairesFilled = isOptionalQuestionnairesFilled
//    }
    
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
    }

}
