//
//  RegisterViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import ChameleonFramework
import FirebaseDatabase
import FirebaseMessaging

class RegisterViewController: UIViewController {
    
    var randomColorHex : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        generateRandomColor()
    }

    func generateRandomColor(){
       // var colorArray = [UIColor.init(hexString: "#FF7E79")!]
        var colorArray = [FlatRed(), FlatRedDark(),  FlatOrange(), FlatOrangeDark(),FlatYellow(), FlatYellowDark(), FlatMagenta(), FlatMagentaDark(), FlatSkyBlue(), FlatGreen(), FlatMint(), FlatPurple(), FlatPlum(), FlatWatermelon(), FlatLime(), FlatPink(), FlatMaroon(), FlatBlue(),FlatPowderBlue(), FlatCoffee(), UIColor.init(hexString: "#FF7E79")!, FlatBlackDark()]
        
        let randomIndex = Int(arc4random_uniform(UInt32(colorArray.count)))
        let randomColor = colorArray[randomIndex]
        randomColorHex = randomColor.hexValue()
    }


    @IBOutlet weak var usernameTextfield: UITextField!
    
    
    
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func signupButton(_ sender: UIButton) {
        
        let username = usernameTextfield.text! + "@circl.com"
        let password = passwordTextfield.text!
    
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: username, password: passwordTextfield.text!) {(user, error) in
            if error != nil {
                switch error{
                case .some(let error as NSError) where error.code == AuthErrorCode.emailAlreadyInUse.rawValue:
                    self.AuthAlert(title: "Sign Up Failed", message: "This username has been claimed, please use another one.")
                    SVProgressHUD.dismiss()
                case .some(let error as NSError) where error.code == AuthErrorCode.networkError.rawValue:
                    self.AuthAlert(title: "Sign Up Failed", message: "There is something wrong with your network connect, please try again.")
                    SVProgressHUD.dismiss()
                case .some(let error as NSError) where error.code == AuthErrorCode.weakPassword.rawValue:
                    self.AuthAlert(title: "Sign Up Failed", message: "Your password is too weak, please choose one with atleast 8 characters.")
                    SVProgressHUD.dismiss()
                case .none:
                    print("your are in")
                    SVProgressHUD.dismiss()
                case .some(let error):
                    print("Login Error: \(error.localizedDescription)")
                    SVProgressHUD.dismiss()
                }
            }
            else{
                let token: [String:AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
                self.postToken(Token: token)
                print("Registration Succesful")
                SVProgressHUD.dismiss()
                self.storeUser(for: username, with: password)
                
                self.performSegue(withIdentifier: "signupSegue", sender: nil
                )
                
                Switcher.updateRootVC()
            }
        }
        
       
    }
    
    func storeUser(for username: String, with password: String) {
        let userDB = Database.database().reference().child("Users")
        let uniqueID = Auth.auth().currentUser?.uid
        
        let userDictionary = ["Username": username, "Password": password, "Reputation": "0", "Color" : randomColorHex, "QuestionViews" : "0", "AnswerLikes" : "0", "AnswerAccepted" : "0", "Reports" : "0"]
        
        userDB.child((uniqueID)!).setValue(userDictionary){
            (error,reference) in
            if error != nil {
                print(error!)
            }
            else {
                print("User info saved succesfully")
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


