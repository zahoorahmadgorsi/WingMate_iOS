//
//  DatabaseColumn.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/11/2020.
//

import Foundation

class DBColumn {
    //general
    static let objectId = "objectId"
    
    //user
    static let gender = "gender"
    static let nick = "nick"
    static let emailVerified = "emailVerified"
    static let username = "username"
    static let email = "email"
    static let password = "password"
    static let isPaidUser = "isPaidUser"
    static let isMandatoryQuestionnairesFilled = "isMandatoryQuestionnairesFilled"
    static let isOptionalQuestionnairesFilled = "isOptionalQuestionnairesFilled"
    static let emailWrong = "emailWrong"
    static let emailNew = "emailNew"
    
    //questionnaires
    static let questionType = "questionType"
    static let displayOrder = "displayOrder"
    static let title = "title"
    static let questionId = "questionId"
    static let optionId = "optionId"
    static let countryFlagImage = "countryFlagImage"
    static let userId = "userId"
    static let selectedOptionIds = "selectedOptionIds"
    
    //terms conditions
    static let isDo = "isDo"
    static let termsType = "termsType"
    static let text = "text"
    static let file = "file"
}

class DBCloudFunction {
    static let cloudFunctionResendVerificationEmail = "resendVerificationEmail"
    static let cloudFunctionUpdateWrongEmail = "updateWrongEmail"
}

class DBTable {
    static let question  = "Question"
    static let questionOption  = "QuestionOption"
    static let userAnswer  = "UserAnswer"
    static let termsConditions  = "TermsConditions"
    static let userProfilePhotoVideo = "UserProfilePhotoVideo2"
}
