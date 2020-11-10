//
//  DatabaseColumn.swift
//  WingMate_iOS
//
//  Created by Muneeb on 09/11/2020.
//

import Foundation

class DatabaseColumn {
    static let objectId = "objectId"
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
