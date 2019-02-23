//
//  Answer.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-29.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

class Answer {
    var sender : String
    var senderColor : String
    var answerText : String
    var likes : String
    var lat : String
    var lon : String
    var id : String
    var peopleWhoLike : [String] = [String]()
    var checkby : Bool = false
    var chatWith : String
    var posterID : String
    var reports: String
    
    
    init(sender:String, senderColor: String, answerText: String, likes:String,lat:String, lon:String, id:String, chatWith:String, posterID : String, reports:String){
        self.sender = sender
        self.senderColor = senderColor
        self.answerText = answerText
        self.likes = likes
        self.lat = lat
        self.lon = lon
        self.id = id
        self.chatWith = chatWith
        self.posterID = posterID
        self.reports = reports
    }
}
