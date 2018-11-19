//
//  LogoutViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

class LogoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutButton(_ sender: UIButton) {
        do
        {try Auth.auth().signOut()
        }
        catch let error {
            print(error)
        }
        Switcher.updateRootVC()
    }
}
