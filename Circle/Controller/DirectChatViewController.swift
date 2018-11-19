//
//  DirectChatViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-31.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

class DirectChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var messageArray : [Message] = [Message]()
    var navTitle = ""
  
    override func viewDidLoad() {
        navigationItem.title = navTitle
        
        
        super.viewDidLoad()
        
        //Register Nibs
        directChatTableView.register(UINib(nibName: "customChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")
        
        retreiveMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chatView.addBorder(side: .top, thickness: 0.5, color: UIColor.lightGray)
        
        directChatTableView.separatorStyle = .none
    }
    
    @IBOutlet weak var directChatTableView: UITableView!
    @IBOutlet weak var chatView: UIView!
    
    
    //Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! customChatCell
        
        cell.chatMessage.text = messageArray[indexPath.row].message
        
        return cell
        
    }
    
    
    func retreiveMessages(){
        let messageDB = Database.database().reference().child("Messages")
        
        messageDB.observeSingleEvent(of: .childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary <String, String>
            let text = snapshotValue["Message"]!
            let sender = snapshotValue["Sender"]!
           // let senderid = snapshotValue["SenderID"]!
            
            let message = Message()
            
            message.message = text
            message.sender = sender
            
            self.messageArray.insert(message, at: 0)
            self.configureTableView()
            self.directChatTableView.reloadData()
            
        }
    }
    
    func configureTableView (){
        directChatTableView.tableFooterView = UIView()
        directChatTableView.rowHeight = UITableView.automaticDimension
        directChatTableView.estimatedRowHeight = 90.0
    }
    

}
