//
//  NewQuestionViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class NewQuestionViewController: UIViewController, UITextViewDelegate{
    
    var keyboardHeight : CGFloat?
    var duration: Double?
    var user = Auth.auth().currentUser
    var lastLocation: CLLocation? = nil
    var cityName = ""
    var userObject: User?
    
    @IBOutlet weak var questionText: UITextView!
    //MARK ViewDidLoad
    //Set Delegate and Initial Placeholder Text
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fetchUser()
        
        questionText.delegate = self
        
        questionText.returnKeyType = UIReturnKeyType.done
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
            //Get Notification for Keyboard Size
            NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardwillHide), name: UIResponder.keyboardWillHideNotification , object: nil)

        // Do any additional setup after loading the view.
        getLocation()
 
    }
    
    func getLocation () {
        lastLocation = CustomLocationManager.shared.locationManager.location
    }
    
 
    //MARK ViewWillApear
    override func viewWillAppear(_ animated: Bool) {
      
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationItem.title = "New"
        
        getCityName()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        questionText.becomeFirstResponder()
    }
    

    //Manage textView
    public func textViewDidChange(_ textView: UITextView) {
        if textView.text.last == "\n" { //Check if last char is newline
           textView.text.removeLast() //Remove newline
//            textView.resignFirstResponder() //Dismiss keyboard
        } else if  textView.text.first == "\n" {
                textView.text.removeFirst()
            }
    }

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool{

        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 280

        }
    
    //Get City From Location
    func getCityName (){
        let geoCoder = CLGeocoder()
        let location = lastLocation
        geoCoder.reverseGeocodeLocation(location!, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Complete address as PostalAddress
            print(placeMark.locality as Any)  //  Import Contacts
            self.cityName = placeMark.locality!
            
            // Location name
            if let locationName = placeMark.name  {
                print(locationName)
            }
            
            // Street address
            if let street = placeMark.thoroughfare {
                print(street)
            }
            
            // Country
            if let country = placeMark.country {
                print(country)
            }
        })
    }

    
    //MARK Keyboard UI
    //Change UI depending on keyboard size
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!){
            self.view.layoutIfNeeded()
            print(self.keyboardHeight!)
        }
    }
    
    @objc func keyboardwillHide(_ notification: Notification){
        UIView.animate(withDuration: duration ?? 0.5){
            self.view.layoutIfNeeded()
        }
    }
    

    //MARK cancelButton
    @IBAction func cancelQuestion(_ sender: UIBarButtonItem) {
    
    resetTextview()
    self.tabBarController?.selectedIndex = 0
        
    }
    
    
    //Mark submitButton
    @IBAction func submitQuestion(_ sender: UIBarButtonItem) {
        if !questionText.text.trimmingCharacters(in: .whitespaces).isEmpty{
        let myquestionDB=Database.database().reference().child("Users").child((user?.uid)!).child("myQuestion")
        let questionsDB = Database.database().reference().child("Questions").childByAutoId()
        let lat = String(lastLocation!.coordinate.latitude)
        let long = String(lastLocation!.coordinate.longitude)
        let uid = user?.uid
        let userColor = userObject?.Color
            let questionDictionary = ["Sender": Auth.auth().currentUser?.email!, "Color" : userColor, "QuestionText": questionText.text!, "Latitude": lat, "Longitude" : long, "City": cityName, "uid" : uid, uid: "True", "Viewcount" : "0", "AnswerCount" : "0"]
        
        questionsDB.setValue(questionDictionary){
            (error, reference) in
            if error != nil {
                print(error!)
            }
            else {
                let key = questionsDB.key
                print("Question Saved Sucessfully")
                self.resetTextview()
                self.tabBarController?.selectedIndex = 1
                myquestionDB.child(key!).setValue(questionDictionary){
                    (error, reference) in
                    if error != nil {
                        print(error!)
                    }
                    else {
                        print("My question saved succesfully")
                    }
                }
            }
        }
        
        } else {
            print ("You need to type something")
        }
    }
    
    
    //resetTextview Function
    
    func resetTextview() {
        
        questionText.endEditing(true)
        questionText.text = ""
        self.view.layoutIfNeeded()
        
        self.tabBarController?.tabBar.isHidden = false
        
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
    
    
}
