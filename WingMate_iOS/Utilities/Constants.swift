//
//  APIKey.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

class ValidationStrings {
    static let kEnterEmail = "Enter your email"
    static let kInvalidEmail = "Invalid email"
    static let kInvalidPassword = "Invalid password"
    static let kVerifyEmail = "Verify your email first"
    static let kInvalidAge = "You must be 21 or above"
    static let kEnterPassword = "Enter your password"
    static let kEnterName = "Enter your name"
    static let kEnterNickname = "Please type your name or nick name"
    static let kEmailSentToVerifyUser = "Email activation link has been sent to your email"
    static let kEmailSentToResetPassword = "Reset password link sent to your email"
    static let kEmailResent = "Email resent successfully"
    static let kEmailResentFailed = "Unable to resend email"
    static let kQuestionnaireOptionSaved = "Questionnaire option saved"
    static let kSelectAnyOption = "Select any option"
    static let kSelectOneBelowOption = "Select one of the below options"
    static let kSelectMultipleBelowOption = "Select one or multiple of the below options"
    static let kAccountRejected = "Your profile has been rejected by the admin"
    static let kAccountPending = "Your profile is waiting for approval. You can not interact with other users right now"
    static let kNotActiveAndNotPaid = "Your account should be active and you should be a paid user to interact with other users"
    static let confirmationForDeteteMedia = "Are you sure you want to delete it? Please note that your profile will go into pending state."
    static let payNowToCompleteProfile = "You need to pay first to complete your profile. Do you want to pay now?"
    static let continueWithOptionalQuestions = "Do you want to fill optional questionnaires?"
    static let needToFillMandatoryQuestions = "Please fill mandatory questionnaires to proceed"
    static let profileUnderScreening = "Your profile is under screening process"
    static let daysLeftForTrialExpiry = "days left for trial. Buy Pro"
    static let photosVideoRequiredToUpload = "Kindly submit your photos/video"
    static let uploadMediaFirst = "You need to upload photos & video first inorder to proceed. Do you wish to continue?"
    static let uploadMediaAndBecomePaidToInteract = "Please upload your photos and video and become a paid user to avail this feature. Do you want to upload photos and video"
    static let uploadNow = "Upload Now"
    static let uploadLater = "Upload Later"
    static let becomePaidUser = "Please become a paid user to avail this feature. Do you want to pay?"
    static let payNow = "Pay Now"
    static let payLater = "Pay Later"
    static let accountInReviewForInteraction = "Your account is under review. Only approved and paid accounts can avail this feature"
    static let deletingVideoWillMakeAccountPending = "Removing video will make account pending. Are you sure you want to continue?"
    static let deletingAllPhotosWillMakeAccountPending = "Removing all photos will make account pending. Are you sure you want to continue?"
    static let min1videoRequired = "Minimum 1 video is required, are you sure you want to continue without uploading it?"
    static let min1PhotoRequired = "Minimum 1 photo is required, are you sure you want to continue without uploading it?"
    static let uploadAtleast1Photo = "Upload at least 1 photo"
    static let uploadVideoToContinue = "Upload video to continue"
}

class UserDefaultKeys {
    static let userObjectKeyUserDefaults = "userObjectKeyUserDefaults"
    static let latestDateTime = "latestDateTime"
}

struct Constants {
    static let actionFileTypeHeading = "Add a File"
    static let actionFileTypeDescription = "Choose a filetype to add..."
    static let camera = "Camera"
    static let photos = "Photos"
    static let video = "Video"
    static let file = "File"
    static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
    static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
    static let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
    static let settingsBtnTitle = "Settings"
    static let cancelBtnTitle = "Cancel"
    static let kAppLang = "APP_LANGUAGE"
    static let ageQuestionId = "OPF5wV3B4e"
    static let trialPeriodDays = 7
    static let timeExpiredInMinsToRecallApis = 1
}

