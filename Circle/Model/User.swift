//
//  User.swift
//  Circle
//
//  Created by Frank Chen on 2018-12-04.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import Foundation

struct User {
    let username: String
    let Color : String
    let questionViews : String
    let answerLikes: String
    let answerAccepted : String
    var latitude : String
    var longitude : String
    var Reputation: Int {
        get{
            return Int(questionViews)! + Int(answerLikes)! * 5 + Int(answerAccepted)! * 25
        }
    }
    
    init(dictionary: [String: Any]) {
        self.username = dictionary["Username"] as? String ?? ""
        self.Color = dictionary["Color"] as? String ?? ""
        self.questionViews = dictionary["QuestionViews"] as? String ?? ""
        self.answerLikes = dictionary["AnswerLikes"] as? String ?? ""
        self.answerAccepted = dictionary["AnswerAccepted"] as? String ?? ""
        self.latitude = dictionary["Latitude"] as? String ?? ""
        self.longitude = dictionary["Longittude"] as? String ?? ""
    }
}
