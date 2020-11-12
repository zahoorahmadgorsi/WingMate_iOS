//
//  DatabaseColumn.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/11/2020.
//

import Foundation

class DatabaseColumn {
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
    
    //questions
    static let questionType = "questionType"
    static let displayOrder = "displayOrder"
    static let title = "title"
    static let questionId = "questionId"
    static let optionId = "optionId"
    static let countryFlagImage = "countryFlagImage"
}

class DatabaseTable {
    static let question  = "Question"
    static let questionOption  = "QuestionOption"
    static let userAnswer  = "UserAnswer"
}
