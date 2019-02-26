//
//  LogoutViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseMessaging

class LogoutViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    let sections = ["My Account", "More Information", "Account Actions"]
    let items = [
        ["Username"],
        ["Reputation","Privacy Policy", "Terms of Service", "Contact Us"],
        ["Log Out"]
    ]
    let token: [String:AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
    
    var user : User?
    let uid = Auth.auth().currentUser?.uid
    @IBOutlet weak var settingsTable: UITableView!
    @IBOutlet weak var reputationLabel: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTable.dataSource = self
        settingsTable.delegate = self
        fetchUser()
        
        self.settingsTable.rowHeight = 44
        settingsTable.register(UINib(nibName: "customSettingsCell", bundle: nil), forCellReuseIdentifier: "customSettingsCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeToken(Token: token)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 0{
                if indexPath.row == 0{
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "customSettingsCell", for: indexPath) as? customSettingsCell
                cell2?.leftLabel.text = "Username"
                cell2?.rightLabel.text = UserDefaults.standard.string(forKey: "Username")
                cell2?.selectionStyle = .none
                    return cell2!
                } else {
                    let cell2 = tableView.dequeueReusableCell(withIdentifier: "customSettingsCell", for: indexPath) as? customSettingsCell
                    cell2?.leftLabel.text = "Phone Number"
                    cell2?.rightLabel.text = "1234567"
                    cell2?.selectionStyle = .none
                    return cell2!
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = items[indexPath.section][indexPath.row]

            return cell
    }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = hexStringToUIColor(hex: "#FF7878")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "reputationSegue", sender: self) 
            }
            tableView.deselectRow(at: indexPath, animated: false)
            if indexPath.row == 1 {
                performSegue(withIdentifier: "privacySegue", sender: self)
            }
            tableView.deselectRow(at: indexPath, animated: false)
            if indexPath.row == 2 {
                performSegue(withIdentifier: "termsSegue", sender: self)
            }
            tableView.deselectRow(at: indexPath, animated: false)
            if indexPath.row == 3 {
                performSegue(withIdentifier: "contactSegue", sender: self)
            }
            tableView.deselectRow(at: indexPath, animated: false)
        }
        if indexPath.section == 2{
        if indexPath.row == 0{
            do
            {try Auth.auth().signOut()
            }
            catch let error {
                print(error)
            }
            Switcher.updateRootVC()
        }
        }
    }
    
    func fetchUser(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.user = User(dictionary: dictionary)
            
            self.reputationLabel.title = "\(self.user?.Reputation ?? 0)"
        })
        {(err) in
            print("Failed to fetch user::", err)
        }
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func removeToken(Token:[String:AnyObject]){
        print("FCM Token: \(Token)")
        let dbRef = Database.database().reference()
        dbRef.child("fcmToken").child(uid!).removeValue()
        
    }
    
}
