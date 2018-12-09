//
//  MeViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class MeViewController: UIViewController, MKMapViewDelegate {
   
    var user : User?
    var lastLocation: CLLocation? = nil
    let userdefaults = UserDefaults.standard

    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var acceptedLabel: UILabel!
    @IBOutlet weak var myMapview: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapview.delegate = self
        
        DispatchQueue.global(qos: .userInitiated).async {
          self.getLocation()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                let viewRegion = MKCoordinateRegion(center: (self.lastLocation?.coordinate)!, latitudinalMeters: 20000, longitudinalMeters: 20000)
                self.myMapview.setRegion(viewRegion, animated: false)
                self.myMapview.addOverlay(MKCircle(center: (self.lastLocation?.coordinate)!, radius: 5000))
                let myAnnotation = MKPointAnnotation()
                myAnnotation.coordinate = (self.lastLocation?.coordinate)!
                myAnnotation.title = self.user?.username
                self.myMapview.addAnnotation(myAnnotation)
                
            }
        }

        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.topItem?.title = userdefaults.string(forKey: "Username")
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else { return MKOverlayRenderer() }
        
        let circle = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor.blue
        circle.fillColor = UIColor(red: 0, green: 0, blue: 255, alpha: 0.1)
        circle.lineWidth = 1
        return circle
    }
    
    func getLocation () {
        lastLocation = CustomLocationManager.shared.locationManager.location
    }
    
}


    

 

