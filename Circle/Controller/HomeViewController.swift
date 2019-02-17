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
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, locationDelegate{
    
    var questionArray : [Question] = [Question]()
    var lastLocation: CLLocation? = nil
    var cityName : String? = nil
    var distance : Double?
    var id = ""
    var selectedIndexPath: IndexPath = IndexPath()
    var user: User?
    let defaults = UserDefaults.standard
    
 
    
    @IBOutlet weak var questionTableView: UITableView!
    @IBOutlet weak var locationLabel: UIBarButtonItem!
    @IBOutlet weak var reputationLabel: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchUser()
            self.retreiveQuestions()
            self.getLocation()
            self.getCityName()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.configureTableView()
                self.tabBarController?.tabBar.isHidden = false
                self.tabBarController?.tabBar.invalidateIntrinsicContentSize()
            }
        }
        
        questionTableView.delegate = self
        questionTableView.dataSource = self
        CustomLocationManager.shared.delegateLoc = self
        
        //Register Custom Cell
       questionTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.view.layoutIfNeeded()
        getLocation()
        questionTableView.reloadData()
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
    }
    
    //MARK cellForRowAt
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customQuestionCell", for: indexPath) as! CustomQuestoinCell
        
        let questionLat = Double(questionArray[indexPath.row].lat)
        let questionLon = Double(questionArray[indexPath.row].lon)
        getDistance(latitude: questionLat!, longitude: questionLon!)
        
        cell.usernameLabel.text = String(questionArray[indexPath.row].sender.dropLast(10))
        cell.usernameLabel.textColor = hexStringToUIColor(hex: questionArray[indexPath.row].senderColor)
        cell.questionTextLabel.text = questionArray[indexPath.row].questionText
        cell.numOfViews.text = ("\(String(questionArray[indexPath.row].viewcount)) views")
        cell.numOfAnswers.text = ("\(String(questionArray[indexPath.row].answercount)) answers")
        
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
        updateMyViewcount(userid: questionArray[indexPath.row].uid)
        
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
    
    func updateMyViewcount(userid:String){
        let userDB = Database.database().reference().child("Users").child(userid).child("QuestionViews")
        
        userDB.keepSynced(true)
        userDB.observeSingleEvent(of: .value) { (snapshot) in
            if let viewsValue = snapshot.value as? String{
                var viewsIntValue = Int(viewsValue)
                viewsIntValue! += 1
                
                userDB.setValue(String(viewsIntValue!))
            }
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
        questionTableView.reloadData()
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
                    let sendercolor = questionObject?["Color"]
                    let latitude = questionObject?["Latitude"]
                    let longitude = questionObject?["Longitude"]
                    let city = questionObject?["City"]
                    let uid = questionObject?["uid"]
                    let viewCount = questionObject?["Viewcount"]
                    let answerCount = questionObject?["AnswerCount"]
                    let key = question.key
                    
                    let question = Question(sender: sender as! String, senderColor: sendercolor as! String, questionText: text as! String, lat: latitude as! String, lon: longitude as! String, city: city as! String, id: key, uid: uid as! String, viewcount : viewCount as! String, answercount: answerCount as! String)
                    self.questionArray.insert(question, at:0)
                }
                    self.configureTableView()
                    self.getLocation()
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
            self.cityName = placeMark.locality
            self.locationLabel.title = "@\(self.cityName!)"
            
        })
    }
    
    func locationFound(_ loc: CLLocation) {
        lastLocation = loc
        print("LOL")
        questionTableView.reloadData()
    }
    
    func fetchUser(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.user = User(dictionary: dictionary)
            
            self.defaults.set(String((self.user?.username.dropLast(10))!), forKey: "Username")
            self.reputationLabel.title = "\(self.user?.Reputation ?? 0)"
        })
        {(err) in
            print("Failed to fetch user::", err)
        }
    }
    //HEXCODE TO UICOLOR
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
