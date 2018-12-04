//
//  HomeViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var questionArray : [Question] = [Question]()
    var lastLocation: CLLocation? = nil
    var distance : Double?
    var id = ""
    var selectedIndexPath: IndexPath = IndexPath()

    
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var locationLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getLocation()
        retreiveQuestions()
        
        questionTableView.delegate = self
        questionTableView.dataSource = self
        
        //Register Custom Cell
       questionTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")
        
        configureTableView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
    
    
    func getDistance(latitude: Double, longitude: Double){
        guard let coordinate0 = lastLocation else {return}
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        distance = distanceInMeters
    }
    

    //Location Tracking
    
    func getLocation () {
        lastLocation = CustomLocationManager.shared.locationManager.location
        getCityName()
    }
    
    //MARK cellForRowAt
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customQuestionCell", for: indexPath) as! CustomQuestoinCell
        
        let questionLat = Double(questionArray[indexPath.row].lat)
        let questionLon = Double(questionArray[indexPath.row].lon)
        getDistance(latitude: questionLat!, longitude: questionLon!)
        
        cell.usernameLabel.text = String(questionArray[indexPath.row].sender.dropLast(10))
        cell.questionTextLabel.text = questionArray[indexPath.row].questionText
        cell.numOfViews.text = ("\(String(questionArray[indexPath.row].viewcount)) views")
        
        if let distance = distance{
        switch distance {
        case 0.0...100.0 :
        cell.distanceLabel.text = "100m"
        case 101...200 :
            cell.distanceLabel.text = "200m"
        case 201...300 :
            cell.distanceLabel.text = "300m"
        case 301...400 :
            cell.distanceLabel.text = "400m"
        case 401...500 :
            cell.distanceLabel.text = "500m"
        case 501...600 :
            cell.distanceLabel.text = "600m"
        case 601...700 :
            cell.distanceLabel.text = "700m"
        case 701...800 :
            cell.distanceLabel.text = "800m"
        case 801...900 :
            cell.distanceLabel.text = "900m"
        default:
        cell.distanceLabel.text = String(format: "%.0f", distance / 1000) + " km"
        }
        }
        return cell
        
    }
    
    //MARK numOfRowsInSection
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionArray.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        id = questionArray[indexPath.row].id
        
        updateViewCount(qid:self.id, question: self.questionArray[indexPath.row], userid: questionArray[indexPath.row].uid)
        
        performSegue(withIdentifier: "questionDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateViewCount(qid:String, question: Question, userid:String? = nil){
        let questionDB = Database.database().reference().child("Questions").child(qid).child("Viewcount")
        let myQuestionDB = Database.database().reference().child("Users").child(userid!).child("myQuestion").child(qid).child("Viewcount")
        
        questionDB.keepSynced(true)
        questionDB.observeSingleEvent(of: .value) { (snapshot) in
            
            if let viewerValue = snapshot.value as? String{
                var viewerIntValue = Int(viewerValue)
                viewerIntValue! += 1
                
                questionDB.setValue(String(viewerIntValue!))
                myQuestionDB.setValue(String(viewerIntValue!))
                
                question.viewcount = String(viewerIntValue!)
                print(question.viewcount)
            }
            self.questionTableView.reloadData()
    }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let destinationVC = segue.destination as! QuestionDetail
        
        if let indexPath = questionTableView.indexPathForSelectedRow {
            destinationVC.selectedQuestion = questionArray[indexPath.row]
            print("prepare\(questionArray[indexPath.row].viewcount)")
            destinationVC.newDistance = distance ?? 0.0
            destinationVC.uniqueID = id
        }
    }

    func configureTableView() {
        questionTableView.tableFooterView = UIView()
        questionTableView.rowHeight = UITableView.automaticDimension
        questionTableView.estimatedRowHeight = 90.0
    }
    
    //MARK Retreive question method
    func retreiveQuestions() {
        let questionDB = Database.database().reference().child("Questions")
        let uid = Auth.auth().currentUser?.uid
        
        questionDB.queryOrdered(byChild: uid!).queryEqual(toValue: nil).observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.questionArray.removeAll()
                
                for question in snapshot.children.allObjects as! [DataSnapshot]{
                    let questionObject = question.value as? [String:AnyObject]
                    let text = questionObject?["QuestionText"]
                    let sender = questionObject?["Sender"]
                    let latitude = questionObject?["Latitude"]
                    let longitude = questionObject?["Longitude"]
                    let city = questionObject?["City"]
                    let uid = questionObject?["uid"]
                    let viewCount = questionObject?["Viewcount"]
                    let key = question.key
                    
                    let question = Question(sender: sender as! String, questionText: text as! String, lat: latitude as! String, lon: longitude as! String, city: city as! String, id: key, uid: uid as! String, viewcount : viewCount as! String)
                    self.questionArray.insert(question, at:0)
                }
                    self.configureTableView()
                    self.questionTableView.reloadData()
                }
            }
        }
    
        
    
    
    //Get City Name Method
    func getCityName (){
        let geoCoder = CLGeocoder()
        guard let location = lastLocation else {return}
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Complete address as PostalAddress
            guard let cityName = placeMark.locality else {return}
            self.locationLabel.title = "@\(cityName)"
            
            
        })
    }
}


