//
//  ChatViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let user = Auth.auth().currentUser
    var friendArray : [Message] = [Message]()
    var username = ""
    var userObject : User?
    lazy var messageDB = Database.database().reference().child("Friends").child((user?.uid)!)
    
    @IBOutlet weak var chatTableview: UITableView!
    
    @IBOutlet weak var reputationLabel: UIBarButtonItem!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchUser()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.tabBarController?.tabBar.isHidden = false
                self.configureTableView()
            }
        }
        
       chatTableview.delegate = self
       chatTableview.dataSource = self
        
        chatTableview.register(UINib(nibName: "FriendsCell", bundle: nil), forCellReuseIdentifier: "friendsCell")
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        DispatchQueue.main.async {
            self.retreiveMessages()
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        chatTableview.separatorStyle = .singleLine
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        messageDB.removeAllObservers()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendsCell", for: indexPath) as! FriendsCell
        
        cell.friendMessage?.numberOfLines = 0
        if friendArray[indexPath.row].senderName == String((userObject?.username.dropLast(10))!){
            cell.friendNameLabel.text = friendArray[indexPath.row].sendToName
        } else{
        cell.friendNameLabel.text = friendArray[indexPath.row].senderName
        }
        cell.friendMessage.text = friendArray[indexPath.row].message
    
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let currentCell = tableView.cellForRow(at: indexPath) as! FriendsCell
            
            username = currentCell.friendNameLabel.text!
            
            self.performSegue(withIdentifier: "chatDetailSegue", sender: self)
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        
        let destinationVC = segue.destination as! DirectChatViewController
        
        if let indexPath = chatTableview.indexPathForSelectedRow{
            destinationVC.navTitle = username
            if friendArray[indexPath.row].sender == user?.uid {
                destinationVC.selectedMessage = friendArray[indexPath.row]
                destinationVC.chatWithUser = friendArray[indexPath.row].sendTo
                destinationVC.chatWithUsername = friendArray[indexPath.row].sendToName
                destinationVC.myUsername = friendArray[indexPath.row].senderName
            } else {
                destinationVC.selectedMessage = friendArray[indexPath.row]
                destinationVC.chatWithUser = friendArray[indexPath.row].sender
                destinationVC.chatWithUsername = friendArray[indexPath.row].senderName
                destinationVC.myUsername = friendArray[indexPath.row].sendToName
                
            }
        }
        
    }

    func retreiveMessages(){

        messageDB.queryOrdered(byChild: (user?.uid)!).queryEqual(toValue: nil).observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.friendArray.removeAll()
                
                for friend in snapshot.children.allObjects as! [DataSnapshot]{
                    let friendObject = friend.value as? [String:AnyObject]
                    
                    let sender = friendObject?["Sender"]
                    let senderName = friendObject?["SenderName"]
                    let text = friendObject?["Message"]
                    let sendto = friendObject?["SendTo"]
                    let sendtoName = friendObject?["SendToName"]
                    let key = friend.key
                    
                    let friend = Message(sender: sender as! String, message: text as! String, senderName: senderName as! String, sendTo: sendto as! String, sendToName: sendtoName as! String, id : key )
                    self.friendArray.insert(friend, at: 0)
                }
                self.configureTableView()
                self.chatTableview.reloadData()
            
            }else{
                self.friendArray.removeAll()
                self.chatTableview.reloadData()
            }
        }
    }
    
    func fetchUser(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.userObject = User(dictionary: dictionary)
            self.reputationLabel.title = "\(self.userObject?.Reputation ?? 0)"
        })
        {(err) in
            print("Failed to fetch user::", err)
        }
    }
  
    func configureTableView() {
        chatTableview.tableFooterView = UIView()
        chatTableview.rowHeight = UITableView.automaticDimension
        chatTableview.estimatedRowHeight = 90.0
        chatTableview.reloadData()
    }
    
    

}
        
    
    

