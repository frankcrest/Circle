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
        cell.coinLabel.setTitle(myQuestionArray[indexPath.row].coinValue, for: .normal)
        cell.distanceLabel.text = "@" + myQuestionArray[indexPath.row].city
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
        let user = Auth.auth().currentUser
        let questionDB = Database.database().reference().child("Users").child((user?.uid)!).child("myQuestion")
        
        questionDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            
            let text = snapshotValue["QuestionText"]!
            let sender = snapshotValue["Sender"]!
            let coin = snapshotValue["CoinValue"]!
            let latitude = snapshotValue["Latitude"]!
            let longitude = snapshotValue["Longitude"]!
            let city = snapshotValue["City"]!
            
            let question = Question()
            
            question.id = snapshot.key
            question.questionText = text
            question.sender = sender
            question.coinValue = coin
            question.lat = latitude
            question.lon = longitude
            question.city = city
            
            self.myQuestionArray.insert(question, at: 0)
            
            self.configureTableView()
            self.askedTableView.reloadData()
            
        }
    }
    
    


}
