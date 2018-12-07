//
//  Message.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-31.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

class Message {
    var sender : String
    var senderName : String
    var message : String
    var sendTo: String
    var sendToName: String

    
    init(sender:String, message:String, senderName:String, sendTo:String, sendToName:String) {
        self.sender = sender
        self.senderName = senderName
        self.message = message
        self.sendTo = sendTo
        self.sendToName = sendToName
    }
}
