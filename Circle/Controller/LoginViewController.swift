//
//  LoginViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseDatabase
import SVProgressHUD
import ChameleonFramework


class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        let token: [String:AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
        
        let username = usernameTextfield.text! + "@circl.com"
        
        print(username)
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: username, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                switch error{
                case .some(let error as NSError) where error.code == AuthErrorCode.wrongPassword.rawValue:
                    self.AuthAlert(title: "Login Failed", message: "You have entered the wrong password, please try again.")
                    SVProgressHUD.dismiss()
                case .some(let error as NSError) where error.code == AuthErrorCode.networkError.rawValue:
                    self.AuthAlert(title: "Login Failed", message: "There is something wrong with your network connection, please try again.")
                    SVProgressHUD.dismiss()
                case .some(let error as NSError) where error.code == AuthErrorCode.userNotFound.rawValue:
                    self.AuthAlert(title: "Login Failed", message: "User not found, please sign up to use our service.")
                    SVProgressHUD.dismiss()
                case .none:
                    print("your are in")
                    SVProgressHUD.dismiss()
                case .some(let error):
                    print("Login Error: \(error.localizedDescription)")
                    SVProgressHUD.dismiss()
                }
            }
            else {
                self.postToken(Token: token)
                self.usernameTextfield.text = ""
                print("Login Sucessful")
                SVProgressHUD.dismiss()
                
                Switcher.updateRootVC()
                
            }
        }
        
    }
    
    func postToken(Token:[String:AnyObject]){
        print("FCM Token: \(Token)")
        let dbRef = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        dbRef.child("fcmToken").child(userID!).setValue(Token)
        
    }
    
    func AuthAlert(title:String, message:String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
    switch action.style{
    case .default:
    print("default")
    
    case .cancel:
    print("cancel")
    
    case .destructive:
    print("destructive")
    
    
    }}))
    self.present(alert, animated: true, completion: nil)
    }

}
