//
//  CustomLocationManager.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

protocol locationDelegate : class{
    func locationFound(_ loc:CLLocation)
}
class CustomLocationManager:NSObject, CLLocationManagerDelegate {
    static let shared = CustomLocationManager()
    var locationManager = CLLocationManager()
    weak var delegateLoc : locationDelegate?
    
    private override init()
    {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest}
    func startTracking()
    {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopTracking()
    {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations{
            self.delegateLoc?.locationFound(locations.last!)
   
            //print("\(index):\(currentLocation)")


        }
    }
}
