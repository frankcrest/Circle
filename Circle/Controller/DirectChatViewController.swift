//
//  DirectChatViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-31.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

class DirectChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    var messageArray : [Message] = [Message]()
    var navTitle = ""
    var keyboardHeight : CGFloat?
    var duration = 0.0
    var tabBarSize : CGFloat = 0
    var chatWithUser = ""
    let user = Auth.auth().currentUser
    
    
    @IBOutlet weak var directChatTableView: UITableView!
    @IBOutlet weak var bottomviewHC: NSLayoutConstraint!
    @IBOutlet weak var botomView: UIView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var textFieldHC: NSLayoutConstraint!
    
    override func viewDidLoad() {
        navigationItem.title = navTitle
        textField.delegate = self
        textField.isScrollEnabled = false
        directChatTableView.delegate = self
        directChatTableView.dataSource = self
        
        
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
        botomView.addBorder(side: .top, thickness: 0.5, color: UIColor.lightGray)
        
        directChatTableView.separatorStyle = .none
    }
    
    
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
            self.bottomviewHC.constant = self.tabBarSize - self.botomView.frame.height
            self.view.layoutIfNeeded()
            print(self.keyboardHeight!)
        }
    }
    
    //Manage textView
    public func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textField.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        print(estimatedSize.height)
        if estimatedSize.height > textFieldHC.constant {
            textFieldHC.constant = estimatedSize.height
            print(estimatedSize.height)
        }
        
        if textView.text.last == "\n" { //Check if last char is newline
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
        
        textField.endEditing(true)
        textField.text = ""
        textFieldHC.constant = CGFloat(60)
        
        self.bottomviewHC.constant = self.tabBarSize - self.botomView.frame.height
        self.view.layoutIfNeeded()
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func retreiveMessages(){
        let messageDB = Database.database().reference().child("Messages").child((user?.uid)!).child(chatWithUser)

        messageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary <String, Any>
            let text = snapshotValue["Message"]!
//            let sender = snapshotValue["Sender"]!
//            let senderid = snapshotValue["SenderID"]!

            let message = Message()

            message.message = text as! String
//            message.sender = sender as! String
//            message.senderid = senderid as! String

            self.messageArray.insert(message, at: 0)
            self.configureTableView()
            self.directChatTableView.reloadData()

        }
    }
    
    @IBAction func submit(_ sender: Any) {
        if !textField.text.trimmingCharacters(in: .whitespaces).isEmpty{
            let message = textField.text
        
            let messagesDB=Database.database().reference().child("Messages").child((user?.uid)!).child(chatWithUser).childByAutoId()
            
            let messageDictionary = ["Message": message]
            
            messagesDB.setValue(messageDictionary){
                (error,reference) in
                if error != nil {
                    print(error!)
                }
                else{
                    let theirMessagesDB = Database.database().reference().child("Messages").child(self.chatWithUser).child((self.user?.uid)!).childByAutoId()
                    let message1 = self.textField.text
                    let messageDictionary = ["Message": message1]
                    
                    theirMessagesDB.setValue(messageDictionary){
                        (error,reference) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            print("success")
                        }
                        
                    }
                    
                    print("Message Saved Succesfully")
                    self.resetTextview()
                }
            }
        } else {
            print("Please type a valid answer")
        }
    }


    func configureTableView (){
        directChatTableView.tableFooterView = UIView()
        directChatTableView.rowHeight = UITableView.automaticDimension
        directChatTableView.estimatedRowHeight = 90.0
    }
    

}
