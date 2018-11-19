//
//  LoginViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
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
        
        let username = usernameTextfield.text! + "@circl.com"
        
        print(username)
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: username, password: passwordTextfield.text!) { (user, error) in
            if error != nil {
                print(error!)
            }
            else {
                self.usernameTextfield.text = ""
                print("Login Sucessful")
                SVProgressHUD.dismiss()
                
                Switcher.updateRootVC()
                
            }
        }
        
    }
    
}
