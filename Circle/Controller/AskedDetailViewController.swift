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
import FirebaseDatabase

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
    var chatWithUid = ""
    var user: User?
    lazy var answerDB = Database.database().reference().child("Answers").child(uniqueID).queryOrdered(byChild: "Likes")
    
    @IBOutlet weak var askDetailTableView: UITableView!
    
    @IBOutlet weak var moreOptions: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchUser()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.configureTableView()
            }
        }
        
        askDetailTableView.delegate = self
        askDetailTableView.dataSource = self
        
        askDetailTableView.register(UINib(nibName: "ReceivedAnswerCell", bundle: nil), forCellReuseIdentifier: "receivedAnswerCell")
        askDetailTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.retreiveAnswers()
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.title = "Answers"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        answerDB.removeAllObservers()
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
            
            cell.selectionStyle = .none
            
            
            cell.separator.addBorder(side: .bottom, thickness: 2, color: hexStringToUIColor(hex: "#FF7E79"))
            cell.usernameLabel.text = String((selectedQuestion?.sender.dropLast(10))!)
            cell.usernameLabel.textColor = hexStringToUIColor(hex: (selectedQuestion?.senderColor)!)
            cell.questionTextLabel.text = selectedQuestion?.questionText
            cell.distanceLabel.text = "@" + (selectedQuestion?.city)!
            
            let viewcountInt = Int((selectedQuestion?.viewcount)!)!
            let answercountInt = Int((selectedQuestion?.answercount)!)!
            cell.numOfViews.text = String(viewcountInt) + " views"
            cell.numOfAnswers.text = String(answercountInt) + " answers"
            
            return cell
            }
            else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "receivedAnswerCell", for: indexPath) as! ReceivedAnswerCell
            
            cell.selectionStyle = .gray
            cell.cellDelegate = self
            cell.questionID = uniqueID
            cell.answerID = answerArray[indexPath.row - 1].id
            cell.answerIndex = indexPath.row - 1
            let answerLat = Double(answerArray[indexPath.row - 1].lat)
            let answerLon = Double(answerArray[indexPath.row - 1].lon)
            getDistance(latitude: answerLat!, longitude: answerLon!)
            
            if Int(answerArray[indexPath.row - 1].reports) ?? 0 < 5 {
            
            cell.userName.text = String(answerArray[indexPath.row - 1].sender.dropLast(10))
            cell.userName.textColor = hexStringToUIColor(hex: answerArray[indexPath.row - 1].senderColor)
            cell.answerText.text = answerArray[indexPath.row - 1].answerText
            cell.numOfLikes.text = String(answerArray[indexPath.row - 1].peopleWhoLike.count) + " likes"
            cell.distanceLabel.text = String(format: "%.0f", distance.rounded(.up)) + " km"
            
            if answerArray[indexPath.row - 1].checkby == true{
                cell.answerCheckMark.tintColor = hexStringToUIColor(hex: "#FF7878")
            } else {
                cell.answerCheckMark.tintColor = UIColor.lightGray
            }
            
            for person in answerArray[indexPath.row - 1].peopleWhoLike {
                if person == Auth.auth().currentUser!.uid{
                    //print(person)
                    cell.answerCheckMark.isHidden = true
                    cell.answerCheckMark.isHidden = false
                    break
                }
            }
            
            }
            return cell
            
            
        }
    }
    
    
    //configure tableview
    func configureTableView() {
        askDetailTableView.tableFooterView = UIView()
        askDetailTableView.rowHeight = UITableView.automaticDimension
        askDetailTableView.estimatedRowHeight = 90.0
    
        
    }
    
    //Retreive Data from firebase
    
    func retreiveAnswers() {
        
        answerDB.observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.answerArray.removeAll()
                
                for answer in snapshot.children.allObjects as! [DataSnapshot]{
                    let answerObject = answer.value as? [String:AnyObject]
                    let text = answerObject?["AnswerText"]
                    let sender = answerObject?["Sender"]
                    let senderColor = answerObject?["Color"]
                    let like = answerObject?["Likes"]
                    let latitude = answerObject?["Latitude"]
                    let longitude = answerObject?["Longitude"]
                    let uid = answerObject?["Uid"]
                    let posterID = answerObject?["PosterID"]
                    let reportCount = answerObject?["Reports"]
                    let key = answer.key
                    
                    let answer = Answer(sender: sender as! String, senderColor: senderColor as! String, answerText: text as! String, likes: like as! String, lat: latitude as! String, lon: longitude as! String, id: key, chatWith: uid as! String, posterID: posterID as! String, reports: reportCount as! String)
                    
                    if let peopleswholike = answerObject?["peopleWhoLike"] as? [String : AnyObject] {
                        for (_, person) in peopleswholike{
                            answer.peopleWhoLike.append(person as! String)
                        }
                    }
                    
                    self.answerArray.insert(answer, at:0)
                    
                }
                self.configureTableView()
                self.askDetailTableView.reloadData()
            }
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
    
    @IBAction func moreOptions(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.deleteQuestion()
            self.navigationController?.popViewController(animated: true)
        }
        let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(action1)
       
        present(alert, animated: true, completion: nil)
    }

    func deleteQuestion(){
        let currentUesr = Auth.auth().currentUser?.uid
        let questionID = selectedQuestion?.id
        let dbRef = Database.database().reference().child("Questions").child(questionID!)
        let answerRef = Database.database().reference().child("Answers").child(questionID!)
        let myRef = Database.database().reference().child("Users").child(currentUesr!).child("myQuestion").child(questionID!)
        dbRef.removeValue()
        answerRef.removeValue()
        myRef.removeValue()
        askDetailTableView.reloadData()
    }
    
    func fetchUser(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.user = User(dictionary: dictionary)
        })
        {(err) in
            print("Failed to fetch user::", err)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
       navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
       
        let destinationVC = segue.destination as! DirectChatViewController
        
            if let indexPath = askDetailTableView.indexPathForSelectedRow{
            destinationVC.navTitle = username
            destinationVC.myUsername =  String((selectedQuestion?.sender.dropLast(10))!)
            destinationVC.chatWithUser = answerArray[indexPath.row - 1].chatWith
            destinationVC.chatWithUsername = String(answerArray[indexPath.row - 1].sender.dropLast(10))
    }
    
}
}


extension AskedDetailViewController : UpdateCheckedDelegate {
    
    func updateCheckedDelegate(index: Int, userID: String, isAdd: Bool) {
        if isAdd {
            for answer in answerArray {
                answer.checkby = false
                self.answerArray[index].checkby = true
            }
        } else {
            if self.answerArray[index].checkby == true {
                for answer in answerArray{
                    answer.checkby = false
                    self.answerArray[index].checkby = false
                }
        }
    }
    askDetailTableView.reloadData()
}
}
