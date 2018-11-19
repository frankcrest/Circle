//
//  AskedDetailViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-11-06.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class AskedDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var selectedQuestion : Question? {
        didSet{
        }
    }
    
    var myQuestionArray : [Question] = [Question]()
    var answerArray : [Answer] = [Answer]()
    var newCity = ""
    var uniqueID = ""
    var distance : Double!
    var questionLocation : CLLocation? = nil
    var username = ""
    
    @IBOutlet weak var askDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retreiveAnswers()
        
        askDetailTableView.delegate = self
        askDetailTableView.dataSource = self
        
        askDetailTableView.register(UINib(nibName: "ReceivedAnswerCell", bundle: nil), forCellReuseIdentifier: "receivedAnswerCell")
        askDetailTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.tabBarController?.tabBar.isHidden = true
        
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Answers"
    }

    //Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if answerArray.count == 0 {
            return 1 }
        else {
            return answerArray.count + 1

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customQuestionCell", for: indexPath) as! CustomQuestoinCell
            
            cell.separator.addBorder(side: .bottom, thickness: 2, color: hexStringToUIColor(hex: "#FF7E79"))
            cell.usernameLabel.text = String((selectedQuestion?.sender.dropLast(10))!)
            cell.questionTextLabel.text = selectedQuestion?.questionText
            cell.coinLabel.setTitle(selectedQuestion?.coinValue, for: .normal)
            cell.distanceLabel.text = "@" + (selectedQuestion?.city)!
            
            
            return cell
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedAnswerCell", for: indexPath) as! ReceivedAnswerCell
            cell.cellDelegate = self
            cell.questionID = uniqueID
            cell.answerID = answerArray[indexPath.row - 1].id
            cell.answerIndex = indexPath.row - 1
            let answerLat = Double(answerArray[indexPath.row - 1].lat)
            let answerLon = Double(answerArray[indexPath.row - 1].lon)
            getDistance(latitude: answerLat!, longitude: answerLon!)
            
            
            cell.userName.text = String(answerArray[indexPath.row - 1].sender.dropLast(10))
            cell.answerText.text = answerArray[indexPath.row - 1].answerText
            cell.numOfLikes.text = String(answerArray[indexPath.row - 1].peopleWhoLike.count) + " likes"
            cell.distanceLabel.text = String(format: "%.0f", distance.rounded(.up)) + " km"
            
            if answerArray[indexPath.row - 1].checkby == Auth.auth().currentUser!.uid {
                cell.answerCheckMark.tintColor = hexStringToUIColor(hex: "#FF7878")
            } else {
                cell.answerCheckMark.tintColor = UIColor.lightGray
            }
            
            for person in answerArray[indexPath.row - 1].peopleWhoLike {
                if person == Auth.auth().currentUser!.uid{
                    print(person)
                    cell.answerCheckMark.isHidden = true
                    cell.answerCheckMark.isHidden = false
                    break
                }
            }
            
            return cell
            
        }
    }
    
    
    
    //Retreive Data from firebase
    
    func retreiveAnswers() {
        let answerDB = Database.database().reference().child("Answers").child(uniqueID)
        answerDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, AnyObject>
            let answer = Answer()
            
            let text = snapshotValue["AnswerText"]!
            let sender = snapshotValue["Sender"]!
            let like = snapshotValue["Likes"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            if let peopleswholike = snapshotValue["peopleWhoLike"] as? [String : AnyObject] {
                for (_, person) in peopleswholike {
                    answer.peopleWhoLike.append(person as! String)
                }
            }
            if let checkby = snapshotValue["CheckedBy"] {
                answer.checkby = checkby as! String
            }
            
            answer.id = snapshot.key
            answer.answerText = text as! String
            answer.sender = sender as! String
            answer.likes = like as! String
            answer.lat = latitude as! String
            answer.lon = longitude as! String
            
            self.answerArray.insert(answer, at: 0)
            
            self.configureTableView()
            self.askDetailTableView.reloadData()
        }
    }
    
    //Get Distance
    func getDistance(latitude: Double, longitude: Double){
       let questionLat = Double(selectedQuestion?.lat ?? "") ?? 0.0
        let questionLon = Double(selectedQuestion?.lon ?? "") ?? 0.0
        let questionText = selectedQuestion?.questionText
        print(questionLat)
        print(questionText!)
        print(questionLon)
        
        
        let coordinate0 = CLLocation(latitude: questionLat, longitude: questionLon)
        let coordinate1 = CLLocation(latitude: latitude, longitude: longitude)
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        let distanceInKm = distanceInMeters / 1000
        distance = distanceInKm.rounded(.up)
    }
    
    //configure tableview
    func configureTableView() {
        askDetailTableView.tableFooterView = UIView()
        askDetailTableView.rowHeight = UITableView.automaticDimension
        askDetailTableView.estimatedRowHeight = 90.0
        
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
    
    //SEGUE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != 0 {
            
            let currentCell = tableView.cellForRow(at: indexPath) as! ReceivedAnswerCell
            
            username = currentCell.userName.text!
            
            self.performSegue(withIdentifier: "directChatSegue", sender: self)
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
       
        let destinationVC = segue.destination as! DirectChatViewController
        
            if let _ = askDetailTableView.indexPathForSelectedRow{
            destinationVC.navTitle = username
    }
    
}
}

extension AskedDetailViewController : UpdateCheckedDelegate {
    
    func updateCheckedDelegate(index: Int, userID: String, isAdd: Bool) {
        if isAdd {
            for answer in answerArray {
                answer.checkby.removeAll()
                self.answerArray[index].checkby = userID
            }
        } else {
            if self.answerArray[index].checkby == userID {
                for answer in answerArray{
                    answer.checkby.removeAll()
                    self.answerArray[index].checkby.removeAll()
                }
        }
    }
    askDetailTableView.reloadData()
}
}
