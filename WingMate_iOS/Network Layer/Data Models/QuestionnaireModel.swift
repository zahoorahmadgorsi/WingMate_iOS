//
//  QuestionnaireModel.swift
//  WingMate_iOS
//
//  Created by Muneeb on 04/12/2020.
//

import Foundation
import Parse

class Question {
    var object: PFObject?
    var options = [Option]()
    var userSavedOptionObject: PFObject?
    init() {}
    init(questionObject: PFObject) {
        self.object = questionObject
    }
}

class Option {
    var isSelected = false
    var object: PFObject?
    
    init() {}
    init(questionOptionObject: PFObject) {
        self.object = questionOptionObject
    }
}
