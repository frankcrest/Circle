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

class QuestionDetail: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var answerArray : [Answer] = [Answer]()
    var questionArray : [Question] = [Question]()
    var user = Auth.auth().currentUser
    var questionLocation: CLLocation? = nil
    var keyboardHeight : CGFloat?
    var initialBottomViewHc : CGFloat?
    var userObject: User?
    var inset : CGFloat?

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userInputBottomViewHC: NSLayoutConstraint!
    
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
            self.retreiveAnswers()
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
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.botomView.addBorder(side: .top, thickness: 0.5, color: UIColor.lightGray )
        resetTextview()
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
            cell.answerID = answerArray[indexPath.row - 1].id
            cell.answerIndex = indexPath.row - 1
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
        let answerDB = Database.database().reference().child("Answers").child(uniqueID).queryOrdered(byChild: "Likes")
        
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
            }
        }
    }
    //fetchUser
    func fetchUser(){
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("Users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, Any> else {return}
            self.userObject = User(dictionary: dictionary)
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
        
            let answerDictionary = ["Sender": Auth.auth().currentUser?.email!,"Color":userColor, "AnswerText": textField.text!, "Latitude": lat, "Longitude" : long, "Likes" : "0", "Uid" : uid]
    
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
            self.answerArray[index].peopleWhoLike.append(userID)
        } else {
            if self.answerArray[index].peopleWhoLike.contains(userID) {
                self.answerArray[index].peopleWhoLike.removeAll{ $0 == userID}
                }
            }
    }
    
}
