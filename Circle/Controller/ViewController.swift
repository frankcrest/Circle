//
//  ViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-21.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
 
        super.viewDidLoad()
        
        CustomLocationManager.shared.locationManager.requestAlwaysAuthorization()
        CustomLocationManager.shared.startTracking()
        
    }

}

