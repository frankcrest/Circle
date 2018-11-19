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
    var distance : Double!
    var id = ""
    var tabBarHeight : CGFloat = 0
    
    @IBOutlet weak var questionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionTableView.delegate = self
        questionTableView.dataSource = self
        
        //Register Custom Cell
       questionTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")
        
        configureTableView()
        retreiveQuestions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getLocation()
        self.tabBarController?.tabBar.isHidden = false
        tabBarHeight = ((tabBarController?.tabBar.frame.size.height)!)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func getDistance(latitude: Double, longitude: Double){
        let coordinate0 = lastLocation
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0?.distance(from: coordinate1)
        let distanceInKm = distanceInMeters! / 1000
        distance = distanceInKm.rounded(.up)
    }
    

    //Location Tracking
    
    func getLocation () {
        lastLocation = CustomLocationManager.shared.locationManager.location
    }
    
    //MARK cellForRowAt
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customQuestionCell", for: indexPath) as! CustomQuestoinCell
        let questionLat = Double(questionArray[indexPath.row].lat)
        let questionLon = Double(questionArray[indexPath.row].lon)
        getDistance(latitude: questionLat!, longitude: questionLon!)
        
        cell.usernameLabel.text = String(questionArray[indexPath.row].sender.dropLast(10))
        cell.questionTextLabel.text = questionArray[indexPath.row].questionText
        cell.coinLabel.setTitle(questionArray[indexPath.row].coinValue, for: .normal)
        cell.distanceLabel.text = String(format: "%.0f", distance) + " km"

        return cell
        
    }
    
    //MARK numOfRowsInSection
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell  = tableView.cellForRow(at: indexPath) as! CustomQuestoinCell
        distance = Double(currentCell.distanceLabel.text!.dropLast(3))
        id = questionArray[indexPath.row].id
        self.performSegue(withIdentifier: "questionDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let destinationVC = segue.destination as! QuestionDetail
        
        if let indexPath = questionTableView.indexPathForSelectedRow {
            destinationVC.selectedQuestion = questionArray[indexPath.row]
            destinationVC.newDistance = distance
            destinationVC.uniqueID = id
            destinationVC.tabBarSize = tabBarHeight
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
        
        questionDB.queryOrdered(byChild: uid!).queryEqual(toValue: nil).observe(.childAdded) { (snapshot) in
            
        let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["QuestionText"]!
            let sender = snapshotValue["Sender"]!
            let coin = snapshotValue["CoinValue"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            
            
            let question = Question()
        
            question.id = snapshot.key
            question.questionText = text
            question.sender = sender
            question.coinValue = coin
            question.lat = latitude
            question.lon = longitude
            
            self.questionArray.insert(question, at: 0)
            
            self.configureTableView()
            self.questionTableView.reloadData()
            
            
        }
    }


}


