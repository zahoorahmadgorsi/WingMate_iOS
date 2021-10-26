//
//  APIKey.swift
//  WingMate_iOS
//
//  Created by Muneeb on 10/11/20.
//

import Foundation
import UIKit

let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate;
let APP_MANAGER = ApplicationManager.shared
var API_TOKEN = ""
var SERVER_DATE_FORMAT: String = "yyyy-MM-dd hh:mm:ss"
var OUTPUT_DATE_FORMAT: String = "E dd/MMM hh:mm a"
var APP_NAME = "Blingui"
var didPressedLoginNowOnEmailVerification = false
var isWrongEmailPressed = false
var oldEmail = ""
