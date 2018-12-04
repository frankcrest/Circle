//
//  AskedViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

class AskedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myQuestionArray : [Question] = [Question]()
    var id = ""
    var city = ""
    
    @IBOutlet weak var askedTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retreiveQuestions()
        
        askedTableView.delegate = self
        askedTableView.dataSource = self
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        //Register Custom Cell
        
        askedTableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "customQuestionCell")
        
        configureTableView()
        askedTableView.separatorStyle = .singleLine

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    //Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myQuestionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customQuestionCell", for: indexPath) as! CustomQuestoinCell
        cell.usernameLabel.text = String(myQuestionArray[indexPath.row].sender.dropLast(10))
        cell.questionTextLabel.text = myQuestionArray[indexPath.row].questionText
        cell.distanceLabel.text = "@" + myQuestionArray[indexPath.row].city
        cell.numOfViews.text = ("\(String(myQuestionArray[indexPath.row].viewcount)) views")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        id = myQuestionArray[indexPath.row].id
        self.performSegue(withIdentifier: "askedDetailSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let destinationVC = segue.destination as! AskedDetailViewController
        
        if let indexPath = askedTableView.indexPathForSelectedRow {
            destinationVC.selectedQuestion = myQuestionArray[indexPath.row]
            destinationVC.newCity = city
            destinationVC.uniqueID = id
        }
    }
    
    
    
    func configureTableView() {
        askedTableView.tableFooterView = UIView()
        askedTableView.rowHeight = UITableView.automaticDimension
        askedTableView.estimatedRowHeight = 90.0
    }
    
    //Retreive Data from firebase
    func retreiveQuestions() {
        let myQuestionDB = Database.database().reference().child("Users")
        let uid = Auth.auth().currentUser?.uid
        
        myQuestionDB.child(uid!).child("myQuestion").observe(DataEventType.value) { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.myQuestionArray.removeAll()
                
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
                    self.myQuestionArray.insert(question, at:0)
                }
                self.configureTableView()
                self.askedTableView.reloadData()
            }
        }
    }
    


}
