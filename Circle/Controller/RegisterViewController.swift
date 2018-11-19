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



class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var usernameTextfield: UITextField!
    
    
    
    @IBOutlet weak var passwordTextfield: UITextField!
    

    @IBAction func signupButton(_ sender: UIButton) {
        
        let username = usernameTextfield.text! + "@circl.com"
        let password = passwordTextfield.text!
    
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: username, password: passwordTextfield.text!) {(user, error) in
            if error != nil {
                print(error!)
            }
            else{
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
        
        let userDictionary = ["Username": username, "Password": password, "Reputation": "100"]
        
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

    
    
}

