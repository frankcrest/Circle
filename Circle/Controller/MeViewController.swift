//
//  MeViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import MapKit
import CoreLocation

class MeViewController: UIViewController, MKMapViewDelegate, locationDelegate{
   
    var user : User?
    var lastLocation: CLLocation? = nil
    let userdefaults = UserDefaults.standard
    let uid = Auth.auth().currentUser?.uid
    lazy var ref = Database.database().reference().child("Users").child(uid!)

    
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var acceptedLabel: UILabel!
    
    @IBOutlet weak var viewsText: UILabel!
    @IBOutlet weak var answerText: UILabel!
    @IBOutlet weak var answerAcceptedText: UILabel!
    
    @IBOutlet weak var reputationLabel: UIBarButtonItem!
    
    @IBOutlet weak var myMapview: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myMapview.delegate = self
        CustomLocationManager.shared.delegateLoc = self
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
    
        DispatchQueue.main.async {
            self.getLocation()
            self.fetchUser()
            guard let last = self.lastLocation?.coordinate else { return}
            let viewRegion = MKCoordinateRegion(center: (last), latitudinalMeters: 30000, longitudinalMeters: 30000)
            self.myMapview.setRegion(viewRegion, animated: false)
            self.myMapview.addOverlay(MKCircle(center: last, radius: 15000))
            let myAnnotation = MKPointAnnotation()
            myAnnotation.coordinate = (self.lastLocation?.coordinate)!
            myAnnotation.title = self.user?.username
            self.myMapview.addAnnotation(myAnnotation)
        }
        self.viewsText.text = "question\nviews"
        self.answerText.text = "answer\nlikes"
        self.answerAcceptedText.text = "answer\naccepted"
        self.viewsLabel.text = self.user?.questionViews
        self.likesLabel.text = self.user?.answerLikes
        self.acceptedLabel.text = self.user?.answerAccepted
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.topItem?.title = userdefaults.string(forKey: "Username")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ref.removeAllObservers()
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
    
    func locationFound(_ loc: CLLocation) {
        let overlays = myMapview.overlays
        self.myMapview.removeOverlays(overlays)
        self.myMapview.addOverlay(MKCircle(center: loc.coordinate, radius: 15000))
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = loc.coordinate
        let username = userdefaults.string(forKey: "Username")
        myAnnotation.title = username
        let annotation = myMapview.annotations
        self.myMapview.removeAnnotations(annotation)
        self.myMapview.addAnnotation(myAnnotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    
    func fetchUser(){

        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.user = User(dictionary: dictionary)
            
                self.viewsLabel.text = self.user?.questionViews
                self.likesLabel.text = self.user?.answerLikes
                self.acceptedLabel.text = self.user?.answerAccepted
            
            
            self.userdefaults.set(String((self.user?.username.dropLast(10))!), forKey: "Username")
            self.reputationLabel.title = "\(self.user?.Reputation ?? 0)"
        })
        {(err) in
            print("Failed to fetch user::", err)
        }
    }
    
}


    

 

