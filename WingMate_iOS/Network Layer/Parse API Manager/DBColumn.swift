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
    static let createdAt = "createdAt"
    static let isAdmin = "isAdmin"
    
    //user
    static let gender = "gender"
    static let nick = "nick"
    static let emailVerified = "emailVerified"
    static let username = "username"
    static let email = "email"
    static let password = "password"
    static let isPaidUser = "isPaidUser"
    static let isPhotosSubmitted = "isPhotosSubmitted"
    static let isVideoSubmitted = "isVideoSubmitted"
    static let isMandatoryQuestionnairesFilled = "isMandatoryQuestionnairesFilled"
    static let isOptionalQuestionnairesFilled = "isOptionalQuestionnairesFilled"
    static let emailWrong = "emailWrong"
    static let emailNew = "emailNew"
    static let aboutMe = "aboutMe"
    static let profilePic = "profilePic"
    static let optionalQuestionAnswersList = "optionalQuestionAnswersList"
    static let mandatoryQuestionAnswersList = "mandatoryQuestionAnswersList"
    static let currentLocation = "currentLocation"
    static let accountStatus = "accountStatus"
    static let isMediaApproved = "isMediaApproved"
    static let groupCategory = "groupCategory"
    static let isMediaPending = "isMediaPending"
    
    //questionnaires
    static let questionType = "questionType"
    static let displayOrder = "displayOrder"
    static let title = "title"
    static let questionId = "questionId"
    static let optionId = "optionId"
    static let countryFlagImage = "countryFlagImage"
    static let userId = "userId"
    static let selectedOptionIds = "selectedOptionIds"
    static let questionOptionsRelation = "questionOptionsRelation"
    static let shortTitle = "shortTitle"
    static let optionsObjArray = "optionsObjArray"
    static let profileDisplayOrder = "profileDisplayOrder"
    
    //terms conditions
    static let isDo = "isDo"
    static let termsType = "termsType"
    static let text = "text"
    static let file = "file"
    
    //photo video
    static let isPhoto = "isPhoto"
    static let videoThumbnail = "videoThumbnail"
    static let fileStatus = "fileStatus"
    
    //fans
    static let fromUser = "fromUser"
    static let toUser = "toUser"
    static let fanType = "fanType"
    
    //instant
    static let INSTANTS_SENDER = "sender"
    static let INSTANTS_RECEIVER = "receiver"
    static let INSTANTS_ID = "instantID"
    
    //messages
   
    static let MESSAGES_SENDER = "sender"
    static let MESSAGES_RECEIVER = "receiver"
    static let MESSAGES_MESSAGE_ID = "messageID"
    static let MESSAGES_MESSAGE = "message"
}

class DBCloudFunction {
    static let cloudFunctionResendVerificationEmail = "resendVerificationEmail"
    static let cloudFunctionUpdateWrongEmail = "updateWrongEmail"
    static let cloudFunctionServerDate = "getServerDate"
    static let pushToAdmin = "pushToAdmin"
    static let pushToUser = "pushToUser"
    
}

class DBTable {
    static let user  = "User"
    static let question  = "Question"
    static let questionOption  = "QuestionOption"
    static let userAnswer  = "UserAnswer"
    static let termsConditions  = "TermsConditions"
    static let userProfilePhotoVideo = "UserProfilePhotoVideo"
    static let fans = "Fans"
    static let instants = "Instants"
    static let USER_CLASS_NAME = "_User"
    static let MESSAGES_CLASS_NAME = "Messages"
}

class QuestionShortTitle {
    static let age  = "Age"
    static let height  = "Height"
    static let lookingFor  = "Looking for"
    static let nationality  = "Nationality"
    static let relationshipStatus = "Relationship status"
}
