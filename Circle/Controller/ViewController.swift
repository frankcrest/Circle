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
    
//    func updateLat(){
//        let userid = Auth.auth().currentUser?.uid
//        let latDB = Database.database().reference().child("Users").child(userid!).child("Latitude")
//
//        latDB.keepSynced(true)
//        latDB.observeSingleEvent(of: .value) { (snapshot) in
//            if let latitudeValue = snapshot.value as? String{
//                var latitudeChangeValue = latitudeValue
//                latitudeChangeValue = "\(CustomLocationManager.shared.locationManager.location?.coordinate.latitude ?? 0)"
//                latDB.setValue(latitudeChangeValue)
//            }
//        }
//    }
//
//
//    func updateLon(){
//        let userid = Auth.auth().currentUser?.uid
//        let longDB = Database.database().reference().child("Users").child(userid!).child("Longitude")
//
//
//        longDB.keepSynced(true)
//        longDB.observeSingleEvent(of: .value) { (snapshot) in
//            if let longValue = snapshot.value as? String{
//                var longChangedValue = longValue
//                longChangedValue = "\(CustomLocationManager.shared.locationManager.location?.coordinate.longitude ?? 0)"
//                longDB.setValue(longChangedValue)
//            }
//        }
//    }

}

