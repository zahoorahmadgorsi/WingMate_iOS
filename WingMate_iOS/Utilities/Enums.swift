//
//  APIKey.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation

enum DeviceType: String {
    case iPhone5 = "iPhone5"
    case iPhone6 = "iPhone6" //6 6s 7 8
    case iPhone6Plus = "iPhone6Plus" //6+ 7+ 8+
    case iPhoneX = "iPhoneX" //X XS
    case iPhoneXSMax = "iPhoneXSMax"
    case iPhoneXR = "iPhoneXR"
    case none = "none"
}

enum Gender: String {
    case male = "male"
    case female = "female"
}

enum LanguageType: String {
    case english = "en"
}

enum StoryboardType: String {
    case main = "Main"
}

enum FileType: String {
    case image = "image"
    case document = "document"
    case audio = "audio"
}

enum AttachmentType: String {
    case camera, photoLibrary
}

enum QuestionType: String {
    case mandatory = "Mandatory"
    case optional = "Optional"
}

enum TermsType: String {
    case photo = "Photo"
    case video = "Video"
    case photoText = "PhotoText"
    case videoText = "VideoText"
}
