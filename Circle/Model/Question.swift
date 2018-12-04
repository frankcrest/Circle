//
//  Question.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

class Question {
    var sender : String
    var questionText : String
    var lat : String
    var lon : String
    var city : String
    var id : String
    var uid : String
    var peopleWhoView : [String] = [String]()
    var viewcount : String
    
    init(sender:String, questionText: String, lat:String, lon:String, city:String, id: String, uid: String, viewcount:String){
        self.sender = sender
        self.questionText = questionText
        self.lat = lat
        self.lon = lon
        self.city = city
        self.id = id
        self.uid = uid
        self.viewcount = viewcount
    }
}
