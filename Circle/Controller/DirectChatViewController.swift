//
//  DirectChatViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-31.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class DirectChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    var messageArray : [Message] = [Message]()
    var navTitle = ""
    var keyboardHeight : CGFloat?
    var bottomViewHCInitial : CGFloat?
    var duration = 0.0
    var chatWithUser = ""
    var chatWithUsername = ""
    var messageCount = 0
    var lastMessage = ""
    var myUsername = ""
    let user = Auth.auth().currentUser
    
    var selectedMessage : Message? {
        didSet{
        }
    }
    
    
    @IBOutlet weak var directChatTableView: UITableView!
    @IBOutlet weak var bottomviewHC: NSLayoutConstraint!
    @IBOutlet weak var botomView: UIView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var textFieldHC: NSLayoutConstraint!
    @IBOutlet weak var userInputHC: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
          self.retreiveMessages()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.configureTableView()

            }
        }
        
        textField.delegate = self
        textField.isScrollEnabled = false
        directChatTableView.delegate = self
        directChatTableView.dataSource = self
        
        //Register Nibs
        directChatTableView.register(UINib(nibName: "customChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")
        directChatTableView.register(UINib(nibName: "customChatCellRight", bundle: nil), forCellReuseIdentifier: "customChatCellRight")
        
        //Get Notification for Keyboard Size
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        bottomViewHCInitial = userInputHC.constant
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
          navigationItem.title = navTitle
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        botomView.addBorder(side: .top, thickness: 0.5, color: UIColor.lightGray)
        directChatTableView.separatorStyle = .none
    }
    
    
    //Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageCount = messageArray.count
        return messageArray.count
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! customChatCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "customChatCellRight", for: indexPath) as! customChatCellRight
        
        if messageArray[indexPath.row].sender == user?.uid{
            cell2.textLabel?.numberOfLines = 0
            cell2.chatMessage.text = messageArray[indexPath.row].message
            lastMessage = messageArray[indexPath.row].message
            cell2.selectionStyle = .none
            return cell2
        } else{
        cell.textLabel?.numberOfLines = 0
        cell.chatMessage.text = messageArray[indexPath.row].message
        lastMessage = messageArray[indexPath.row].message
        cell.selectionStyle = .none
        return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.resignFirstResponder()
    }
    
    @IBAction func moreOptions(_ sender: UIBarButtonItem) {
        let optionsAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let blockAction = UIAlertAction(title: "Block", style: .destructive) { (UIAlertAction) in
            self.blockUser()
        }
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { (UIAlertAction) in
            self.showReportActions(reportMethod: self.reportUser)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        optionsAlert.addAction(blockAction)
        optionsAlert.addAction(reportAction)
        optionsAlert.addAction(cancelAction)
        
        present(optionsAlert, animated: true, completion: nil)
    }
    
    func showReportActions(reportMethod: @escaping () -> Void){
        let reportAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction1 = UIAlertAction(title: "Harassment or hate speech", style: .destructive) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction2 = UIAlertAction(title: "Violence or threat of violence", style: .destructive) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction3 = UIAlertAction(title: "Sexually explicity content", style: .destructive) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction4 = UIAlertAction(title: "Inappropriate or graphic content", style: .destructive) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction5 = UIAlertAction(title: "I just don't want to see it", style: .default) { (UIAlertAction) in
            reportMethod()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (UIAlertAction) in
            self.directChatTableView.reloadData()
        }
        
        reportAlert.addAction(reportAction1)
        reportAlert.addAction(reportAction2)
        reportAlert.addAction(reportAction3)
        reportAlert.addAction(reportAction4)
        reportAlert.addAction(reportAction5)
        reportAlert.addAction(cancelAction)
        
        present(reportAlert, animated: true,completion: nil)
    }
    
    func reportUser(){
        let userID = user?.uid
        var willBlockUserID : String
        if userID == messageArray[0].sendTo{
            willBlockUserID = messageArray[0].sender
        } else{
            willBlockUserID = messageArray[0].sendTo
        }
        
        //let dictionary = [userID:willBlockUserID]
        
        //let dbRef = Database.database().reference().child("Blocklist").child((user?.uid)!)
        //let blockUserRef = Database.database().reference().child("Blocklist").child(willBlockUserID)
        let UserToReport = Database.database().reference().child("Users").child(willBlockUserID).child("Reports")
        //dbRef.updateChildValues(dictionary)
        //blockUserRef.updateChildValues(dictionary)
        
        UserToReport.observeSingleEvent(of: .value) { (snapshot) in
            let reportCount = snapshot.value as? String
            let newReportCount = Int(reportCount!)! + 1
            UserToReport.setValue(String(newReportCount))
        }
        let alert = UIAlertController(title: "User Reported", message: "Thank you for reporting \(chatWithUsername), to ignore this user, please use the block feature.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    func blockUser(){
        let userID = user?.uid
        var willBlockUserID : String
        if user?.uid == messageArray[0].sendTo{
            willBlockUserID = messageArray[0].sender
        } else{
            willBlockUserID = messageArray[0].sendTo
        }
        
        let dictionary = [willBlockUserID:"true"]
        let reverseDictionary = [userID:"true"]
        let blockedDictionary = [userID:"True"]
        
        let dbRef = Database.database().reference().child("Blocklist").child((user?.uid)!)
        let blockUserRef = Database.database().reference().child("Blocklist").child(willBlockUserID)
        dbRef.updateChildValues(dictionary)
        blockUserRef.updateChildValues(reverseDictionary)
        
        let friendRef = Database.database().reference().child("Friends").child(userID!).child(willBlockUserID)
        friendRef.updateChildValues(blockedDictionary)
        
        
        
        
        self.navigationController?.popViewController(animated: true)
        
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
            if #available(iOS 11.0, *){
                self.bottomviewHC.constant = self.keyboardHeight! - self.view.safeAreaInsets.bottom
            }else{
                self.bottomviewHC.constant = self.keyboardHeight!
            }
            self.view.layoutIfNeeded()
            print(self.keyboardHeight!)
        }
        scrollToBottom()
    }
    
    @objc func keyboardwillHide(_ notification: Notification){
        UIView.animate(withDuration: duration){
            self.userInputHC.constant = self.bottomViewHCInitial!
            self.bottomviewHC.constant = 0
            self.view.layoutIfNeeded()
            //print(self.keyboardHeight!)
        }
    }
    
    //Manage textView
    public func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textField.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height > userInputHC.constant {
            userInputHC.constant = estimatedSize.height
            print(estimatedSize.height)
        } else if estimatedSize.height < userInputHC.constant && estimatedSize.height > bottomViewHCInitial! {
            userInputHC.constant = estimatedSize.height
        } else if estimatedSize.height < userInputHC.constant && estimatedSize.height < bottomViewHCInitial! {
            userInputHC.constant = bottomViewHCInitial!
        }
        
        if textView.text.last == "\n" || textView.text.first == "\n"  { //Check if last char is newline
            textView.text.removeLast() //Remove newline
            textView.resignFirstResponder() //Dismiss keyboard
        } else if textView.text.first == "\n" {
            textView.text.removeFirst()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 140
        
    }
    
    func resetTextview() {
        textField.text = ""
        userInputHC.constant = bottomViewHCInitial!
        self.tabBarController?.tabBar.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    
    func retreiveMessages(){
        let messageDB = Database.database().reference().child("Messages").child((user?.uid)!).child(chatWithUser)

        messageDB.observe(.childAdded) { (snapshot) in
            if let snapshotValue = snapshot.value as? Dictionary <String, String> {
            let text = snapshotValue["Message"]
            let sender = snapshotValue["Sender"]
            let senderName = snapshotValue["SenderName"]
            let sendto = snapshotValue["SendTo"]
            let sendtoName = snapshotValue["SendToName"]
            let key = snapshot.key

                let message = Message(sender: sender!, message: text!, senderName: senderName!, sendTo: sendto!, sendToName: sendtoName!, id: key)

            self.messageArray.append(message)
            self.configureTableView()
            self.directChatTableView.reloadData()
            self.scrollToBottom()

        }
    }
    }
    
    @IBAction func submit(_ sender: Any) {
        if !textField.text.trimmingCharacters(in: .whitespaces).isEmpty{
            let message = textField.text
        
            let messagesDB=Database.database().reference().child("Messages").child((user?.uid)!).child(chatWithUser).childByAutoId()
            
            let messageDictionary = ["Message": message, "Sender": user?.uid, "SenderName" : myUsername, "SendTo": chatWithUser, "SendToName": chatWithUsername]
            
            messagesDB.setValue(messageDictionary){
                (error,reference) in
                if error != nil {
                    print(error!)
                }
                else {
                    let theirMessagesDB = Database.database().reference().child("Messages").child(self.chatWithUser).child((self.user?.uid)!).childByAutoId()
                    let message1 = self.textField.text
                    let messageDictionary = ["Message": message1, "Sender":self.user?.uid, "SenderName": self.myUsername, "SendTo": self.chatWithUser, "SendToName": self.chatWithUsername]
                    
                    theirMessagesDB.setValue(messageDictionary){
                        (error,reference) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            let chatsDB = Database.database().reference().child("Friends").child((self.user?.uid)!).child(self.chatWithUser)
                            let message2 = self.messageArray[self.messageCount - 1].message
                            let messageDictionary = ["Message": message2, "Sender":self.user?.uid, "SenderName": self.myUsername, "SendTo": self.chatWithUser, "SendToName": self.chatWithUsername]
                            chatsDB.setValue(messageDictionary){
                                (error, reference) in
                                if error != nil{print(error!)
                                }else{
                                    let theirChatsDB = Database.database().reference().child("Friends").child(self.chatWithUser).child((self.user?.uid)!)
                                    let message3 = self.messageArray[self.messageCount - 1].message
                                    let messageDictionary = ["Message": message3, "Sender" : self.user?.uid, "SenderName":self.myUsername, "SendTo": self.chatWithUser, "SendToName": self.chatWithUsername]
                                    theirChatsDB.setValue(messageDictionary){
                                        (errpr, reference) in
                                        if error != nil {print(error!)} else{
                                            print("Sucess")
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    print("Message Saved Succesfully")
                    self.resetTextview()
                }
            }
        } else {
            print("Please type a valid answer")
        }
        directChatTableView.reloadData()
        scrollToBottom()
    }

    func configureTableView (){
        directChatTableView.tableFooterView = UIView()
        directChatTableView.rowHeight = UITableView.automaticDimension
        directChatTableView.estimatedRowHeight = 90.0
    }
    
    func scrollToBottom(){
        if self.messageArray.count > 0 {
            let indexPath = IndexPath(row: self.messageArray.count - 1, section: 0)
            self.directChatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

}
