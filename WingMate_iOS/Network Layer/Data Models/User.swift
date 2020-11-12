//
//  User.swift
//  WingMate_iOS
//
//  Created by Muneeb on 14/10/2020.

import Foundation

struct User : Codable {
    let objectId : String?
    let gender : String?
    let nick : String?
    let emailVerified : String?
    let username : String?
    let email : String?
    let isPaidUser : Bool?
    let isMandatoryQuestionnairesFilled : Bool?
    let isOptionalQuestionnairesFilled : Bool?
//
//    init(userId: String, email: String, isEmailVerified: Bool, gender: String, nickName: String, isPaidUser: Bool, isMandatoryQuestionnairesFilled: Bool, isOptionalQuestionnairesFilled: Bool) {
//        self.userId = userId
//        self.email = email
//        self.isEmailVerified = isEmailVerified
//        self.gender = gender
//        self.nickName = nickName
//        self.isPaidUser = isPaidUser
//        self.isMandatoryQuestionnairesFilled = isMandatoryQuestionnairesFilled
//        self.isOptionalQuestionnairesFilled = isOptionalQuestionnairesFilled
//    }

}
