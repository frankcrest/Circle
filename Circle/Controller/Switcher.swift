//
//  Switcher.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//
import Foundation
import Firebase
import UIKit

class Switcher {
    
    static func updateRootVC(){
        
        var rootVC : UIViewController?
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainTabController") as! TabBarViewController
            } else {
                rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! UINavigationController
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = rootVC
            
        }
}

}
