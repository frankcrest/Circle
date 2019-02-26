//
//  Question.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

class Question : Equatable {
    static func == (lhs: Question, rhs: Question) -> Bool {
       return lhs.reports == rhs.reports &&
        lhs.lat == rhs.lat &&
        lhs.lon == rhs.lon
    }
    
    var sender : String
    var senderColor : String
    var questionText : String
    var lat : String
    var lon : String
    var city : String
    var id : String
    var uid : String
    var peopleWhoView : [String] = [String]()
    var viewcount : String
    var answercount : String
    var reports : String
    
    init(sender:String, senderColor:String, questionText: String, lat:String, lon:String, city:String, id: String, uid: String, viewcount:String, answercount:String, reports: String){
        self.sender = sender
        self.senderColor = senderColor
        self.questionText = questionText
        self.lat = lat
        self.lon = lon
        self.city = city
        self.id = id
        self.uid = uid
        self.viewcount = viewcount
        self.answercount = answercount
        self.reports = reports
    }
}
