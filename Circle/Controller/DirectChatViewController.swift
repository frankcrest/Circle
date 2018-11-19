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
    var keyboardHeight : CGFloat?
    var duration = 0.0
    var tabBarSize : CGFloat = 0
    
    override func viewDidLoad() {
        navigationItem.title = navTitle
        
        
        super.viewDidLoad()
        
        //Register Nibs
        directChatTableView.register(UINib(nibName: "customChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")
        
        retreiveMessages()
        
        //Get Notification for Keyboard Size
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        configureTableView()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chatView.addBorder(side: .top, thickness: 0.5, color: UIColor.lightGray)
        
        directChatTableView.separatorStyle = .none
    }
    
    @IBOutlet weak var directChatTableView: UITableView!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var bottomviewHC: NSLayoutConstraint!
    @IBOutlet weak var botomView: UIView!
    
    
    //Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! customChatCell
        
        cell.chatMessage.text = messageArray[indexPath.row].message
        
        return cell
        
    }
    
    //MARK Keyboard UI
    //Change UI depending on keyboard size
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double)!
        UIView.animate(withDuration: duration){
            self.bottomviewHC.constant = self.keyboardHeight!
            self.view.layoutIfNeeded()
            print(self.keyboardHeight!)
        }
    }
    
    @objc func keyboardwillHide(_ notification: Notification){
        UIView.animate(withDuration: duration){
            self.bottomviewHC.constant = 0
            //self.tabBarSize - self.botomView.frame.height
            self.view.layoutIfNeeded()
            print(self.keyboardHeight!)
        }
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
