//
//  QuestionDetail.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-29.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import ChameleonFramework
import FirebaseDatabase

class QuestionDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var answerArray : [Answer] = [Answer]()
    var questionArray : [Question] = [Question]()
    var user = Auth.auth().currentUser
    var questionLocation: CLLocation? = nil
    var keyboardHeight : CGFloat?
    var initialBottomViewHc : CGFloat?
    var userObject: User?
    var inset : CGFloat?
    var indexPathForReport : IndexPath!
    let answerDB = Database.database().reference().child("Answers")

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userInputBottomViewHC: NSLayoutConstraint!
    @IBOutlet weak var optionsLabel: UIBarButtonItem!
    
    var duration = 0.0
    var newDistance = 0.0
    var lastLocation: CLLocation? = nil
    @IBOutlet weak var botomView: UIView!
    var uniqueID = ""

    var selectedQuestion : Question? {
        didSet{
        }
    }

    @IBOutlet weak var answerTableView: UITableView!
    @IBOutlet weak var textField: UITextView!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.getLocation()
            self.fetchUser()
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                self.configureTableView()
            }
        }

        initialBottomViewHc = userInputBottomViewHC.constant

        answerTableView.delegate = self
        answerTableView.dataSource = self
        textField.delegate = self
        textField.isScrollEnabled = false
        
        //Register Nibs
        answerTableView.register(UINib(nibName: "AnswerCell", bundle: nil), forCellReuseIdentifier: "customAnswerCell")
        answerTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")
        
        //Get Notification for Keyboard Size
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillHide), name: UIResponder.keyboardWillHideNotification , object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.retreiveAnswers()
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.botomView.addBorder(side: .top, thickness: 0.5, color: UIColor.lightGray )
        resetTextview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        answerDB.removeAllObservers()
    }
    
    func configureTableView() {
        answerTableView.tableFooterView = UIView()
        answerTableView.rowHeight = UITableView.automaticDimension
        answerTableView.estimatedRowHeight = 90.0
        answerTableView.reloadData()    
        
    }
    
    //Location Tracking
    
    func getLocation () {
        lastLocation = CustomLocationManager.shared.locationManager.location
    }
    
    
    //MARK Keyboard UI
    //Change UI depending on keyboard size
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double)!
        UIView.animate(withDuration: duration){
           if #available(iOS 11.0, *){
            self.inset = self.view.safeAreaInsets.bottom
            self.heightConstraint.constant = self.keyboardHeight! - self.view.safeAreaInsets.bottom
           }else{
            self.heightConstraint.constant = self.keyboardHeight!
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardwillHide(_ notification: Notification){
        UIView.animate(withDuration: duration){
            self.userInputBottomViewHC.constant = self.initialBottomViewHc!
            self.heightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    //Manage textView
    public func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textField.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        if estimatedSize.height > userInputBottomViewHC.constant {
        userInputBottomViewHC.constant = estimatedSize.height
        } else if estimatedSize.height < userInputBottomViewHC.constant && estimatedSize.height > initialBottomViewHc! {
            userInputBottomViewHC.constant = estimatedSize.height
        } else if estimatedSize.height < userInputBottomViewHC.constant && estimatedSize.height < initialBottomViewHc! {
            userInputBottomViewHC.constant = initialBottomViewHc!
        }

        if textView.text.last  == "\n" || textView.text.first == "\n" { //Check if last char is newline
            textView.text.removeLast() //Remove newline
            textView.resignFirstResponder() //Dismiss keyboard
        } else if textView.text.first == "\n" {
            textView.text.removeFirst()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 140
        
    }
    
    
    
    //Tableviwe Delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if answerArray.count == 0 {
            return 1}
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
            switch newDistance {
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
                cell.distanceLabel.text = String(format: "%.0f", newDistance / 1000) + " km"
            }
            let viewcountInt = Int((selectedQuestion?.viewcount)!)!
            let answercountInt = Int((selectedQuestion?.answercount)!)!
            cell.numOfViews.text = String(viewcountInt) + " views"
            cell.numOfAnswers.text = String(answercountInt) + " answers"
         
                
                return cell
            }
         else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customAnswerCell", for: indexPath) as! AnswerCell
            
            cell.selectionStyle = .none
            
            cell.cellDelegate = self
            cell.questionID = uniqueID
            print("the index \(answerArray)")
            cell.answerID = answerArray[indexPath.row - 1].id
            print("the index path is currently \(indexPath.row - 1)")
            cell.answerIndex = indexPath.row
            cell.usernameLabel.text = String(answerArray[indexPath.row - 1].sender.dropLast(10))
            cell.usernameLabel.textColor = hexStringToUIColor(hex: answerArray[indexPath.row - 1].senderColor)
            cell.answerTextLabel.text = answerArray[indexPath.row - 1].answerText
            cell.numberofLikes.text = String(answerArray[indexPath.row - 1].peopleWhoLike.count) + " likes"
            
            for person in answerArray[indexPath.row - 1].peopleWhoLike {
                if person == Auth.auth().currentUser!.uid{
            
                    cell.likeButtonOutlet.isHidden = true
                    cell.likedButtonOutlet.isHidden = false
                    break
            }
            }

            return cell

        }
    }
    
    //Swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        if answerArray[indexPath.row - 1].chatWith == user?.uid{
            let trashAction = UIContextualAction(style: .destructive, title: "Trash") { (action, view, handler) in
                print("Trash action tapped")
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let action = UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
                    self.deleteMessage(index: indexPath)
                    //self.answerArray.remove(at: indexPath.row - 1)
                    print("remove at \(indexPath.row - 1)")
                })
                let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(action1)
                self.present(alert, animated: true, completion: nil)
            }
            trashAction.backgroundColor = hexStringToUIColor(hex: "#FF7E79")
            trashAction.image = UIImage(named: "trash")
            let configuration = UISwipeActionsConfiguration(actions: [trashAction])
            answerTableView.reloadData()
            return configuration
        } else {
        
        let flagAction = UIContextualAction(style: .normal, title: "Flag") { (action, view, handler) in
            
            print("Flag action tapped")
            self.showReportActions(reportMethod: self.reportMessage)
            self.indexPathForReport = indexPath
        }
        flagAction.backgroundColor = hexStringToUIColor(hex: "#FF7E79")
        flagAction.image = UIImage(named: "flag")
        let configuration = UISwipeActionsConfiguration(actions: [flagAction])
        answerTableView.reloadData()
        return configuration
    }
    }
    
    //More options for flagging
    @IBAction func moreOptions(_ sender: UIBarButtonItem) {
        
        let optionsAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "Report", style: .default) { (UIAlertAction) in
            self.showReportActions(reportMethod: self.reportQuestion)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionsAlert.addAction(reportAction)
        optionsAlert.addAction(cancelAction)
        
        present(optionsAlert, animated: true, completion: nil)
       
    }
    
    func showReportActions(reportMethod: @escaping () -> Void){
        let reportAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction1 = UIAlertAction(title: "Harassment or hate speech", style: .default) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction2 = UIAlertAction(title: "Violence or threat of violence", style: .default) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction3 = UIAlertAction(title: "Sexually explicity content", style: .default) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction4 = UIAlertAction(title: "Inappropriate or graphic content", style: .default) { (UIAlertAction) in
            reportMethod()
        }
        let reportAction5 = UIAlertAction(title: "I just don't want to see it", style: .default) { (UIAlertAction) in
            reportMethod()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){ (UIAlertAction) in
            self.answerTableView.reloadData()
            }
        
        reportAlert.addAction(reportAction1)
        reportAlert.addAction(reportAction2)
        reportAlert.addAction(reportAction3)
        reportAlert.addAction(reportAction4)
        reportAlert.addAction(reportAction5)
        reportAlert.addAction(cancelAction)
        
        present(reportAlert, animated: true,completion: nil)
    }
    
    func reportQuestion(){
        let key = selectedQuestion?.id
        let uid = selectedQuestion?.uid
        let currentId = Auth.auth().currentUser?.uid
        let post = [currentId : "true"]
        if let questionID = key, let reportedUser = uid{
            let dbRef = Database.database().reference().child("Questions").child(questionID)
            let reportRef = Database.database().reference().child("Questions").child(questionID).child("Reports")
            let userReportRef = Database.database().reference().child("Users").child(reportedUser).child("myQuestion").child(questionID).child("Reports")
            reportRef.observeSingleEvent(of: .value) { (snapshot) in
                let reportCount = snapshot.value as? String
                let newReportCount = Int(reportCount!)! + 1
                reportRef.setValue(String(newReportCount))
                userReportRef.setValue(String(newReportCount))
                dbRef.updateChildValues(post)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func reportMessage(){
        let key = selectedQuestion?.id
        let reportedAnswerID = answerArray[indexPathForReport.row - 1].id
        let currentId = Auth.auth().currentUser?.uid
        let post = [currentId : "true"]
        
        if let questionID = key{
        let dbRef = Database.database().reference().child("Answers").child(questionID).child(reportedAnswerID)
        dbRef.updateChildValues(post)
        }
        answerTableView.reloadData()
    }
    
    func deleteMessage(index:IndexPath){
        let questionKey = selectedQuestion?.id
        let answerKey = answerArray[index.row - 1].id
        if let questionID = questionKey{
            let dbRef = Database.database().reference().child("Answers").child(questionID).child(answerKey)
            let userRef = Database.database().reference().child("Users").child(user!.uid).child("myAnswer").child(answerKey)
            
            dbRef.removeValue()
            userRef.removeValue()
            
            answerTableView.reloadData()
        }
    }
    
    //Editing Style
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        } else{
            return true
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

    
    //Reset textview
    func resetTextview() {
        
        textField.endEditing(true)
        textField.text = ""
        
        userInputBottomViewHC.constant = initialBottomViewHc!
    }
    
    //MARK Retreive Answers method
    func retreiveAnswers() {
        let uid = Auth.auth().currentUser?.uid
            //.queryOrdered(byChild: "Likes")
        
        answerDB.child(uniqueID).queryOrdered(byChild: uid!).queryEqual(toValue: nil).observe(DataEventType.value) { (snapshot) in
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
                    let key = answer.key
                    
                    let answer = Answer(sender: sender as! String, senderColor: senderColor as! String, answerText: text as! String, likes: like as! String, lat: latitude as! String, lon: longitude as! String, id: key, chatWith: uid as! String)
                    
                    if let peopleswholike = answerObject?["peopleWhoLike"] as? [String : AnyObject] {
                        for (_, person) in peopleswholike{
                            answer.peopleWhoLike.append(person as! String)
                        }
                    }
                     self.answerArray.insert(answer, at:0)
                }
                self.configureTableView()
                self.answerTableView.reloadData()
            } else{
                self.answerArray.removeAll()
                self.answerTableView.reloadData()
            }
        }
    }
    //fetchUser
    func fetchUser(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observe(.value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.userObject = User(dictionary: dictionary)
            self.optionsLabel.title = "\(self.userObject?.Reputation ?? 0)"
        })
        {(err) in
            print("Failed to fetch user::", err)
        }
    }
    
    //MARK Retreive question method

    @IBAction func submitButton(_ sender: UIButton) {
    
        if !textField.text.trimmingCharacters(in: .whitespaces).isEmpty{
        let myquestionDB=Database.database().reference().child("Users").child((user?.uid)!).child("myAnswer")
        let answerDB = Database.database().reference().child("Answers").child(uniqueID).childByAutoId()
        let lat = String(lastLocation!.coordinate.latitude)
        let long = String(lastLocation!.coordinate.longitude)
        let uid = user?.uid
        let userColor = userObject?.Color
        let userRep = (userObject?.Reputation)
        
            let answerDictionary = ["Sender": Auth.auth().currentUser?.email!,"Color":userColor, "AnswerText": textField.text!, "Latitude": lat, "Longitude" : long, "Likes" : "0", "Uid" : uid, "rep" : "\(userRep ?? 0)"]
    
            answerDB.setValue(answerDictionary){
            (error,reference) in
            if error != nil {
                print(error!)
            }
            else{
                let key = answerDB.key
                myquestionDB.child(key!).setValue(answerDictionary)
                self.updateAnswerCount()
                print("My Answer Saved Succesfully")
                self.resetTextview()
                }
            }
            } else {
                print("Please type a valid answer")
            }
    }
    
    func updateAnswerCount(){
        let questionDB = Database.database().reference().child("Questions").child((selectedQuestion?.id)!).child("AnswerCount")
        let myquestionDB = Database.database().reference().child("Users").child((selectedQuestion?.uid)!).child("myQuestion").child((selectedQuestion?.id)!).child("AnswerCount")
        
        questionDB.observeSingleEvent(of: .value) { (snapshot) in
            if let answerCount = snapshot.value as? String {
            var answerCountInt = Int(answerCount)
            answerCountInt! += 1
            let replyCountIntBackToString = String(answerCountInt!)
            questionDB.setValue(replyCountIntBackToString)
            myquestionDB.setValue(replyCountIntBackToString)
                
                self.selectedQuestion?.answercount = replyCountIntBackToString
        }
            self.answerTableView.reloadData()
        
    }
}
}

extension QuestionDetail : UpdateLikeButtonDelegate {

    func updateAnswerArrayDelegate(index: Int, userID: String, isAdd: Bool) {
        if isAdd {
            self.answerArray[index - 1].peopleWhoLike.append(userID)
        } else {
            if self.answerArray[index - 1].peopleWhoLike.contains(userID) {
                self.answerArray[index - 1].peopleWhoLike.removeAll{ $0 == userID}
                }
            }
    }
    
}
    
