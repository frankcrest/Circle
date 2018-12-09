//
//  AnswerCell.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-29.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

protocol UpdateLikeButtonDelegate : class {
    func updateAnswerArrayDelegate(index: Int, userID: String, isAdd: Bool)
}

class AnswerCell: UITableViewCell {
    weak var cellDelegate : UpdateLikeButtonDelegate?
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var likedButtonOutlet: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .gray
    
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        likeButtonOutlet.isHidden = false
        likedButtonOutlet.isHidden = true
    }
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var answerTextLabel: UILabel!
    @IBOutlet weak var numberofLikes: UILabel!
    
    var questionID : String!
    var answerID : String!
    var answerIndex : Int!
    var userID = Auth.auth().currentUser?.uid
    
    @IBAction func likeButton(_ sender: UIButton) {
        
        likeButtonOutlet.isEnabled = false
        let ref = Database.database().reference().child("Answers")
        let keyToPost = userID!

        ref.child(questionID).child(answerID).observeSingleEvent(of: .value) { (snapshot) in

            if let _ = snapshot.value as? [String: AnyObject] {
                let updateLikes: [String : Any] =  ["peopleWhoLike/\(keyToPost)" : Auth.auth().currentUser!.uid]
                ref.child(self.questionID).child(self.answerID).updateChildValues(updateLikes, withCompletionBlock : {(error, ref) in

                    if error != nil {
                        print (error!)

                    } else {
                        self.cellDelegate?.updateAnswerArrayDelegate(index: self.answerIndex, userID: self.userID!, isAdd: true)

                        let ref = Database.database().reference().child("Answers")
                        ref.child(self.questionID).child(self.answerID).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let properties = snapshot.value as? [String : AnyObject] {
                                if let likes = properties["peopleWhoLike"] as? [String : AnyObject]{
                                    let count = likes.count
                                    self.numberofLikes.text = "\(count) likes"
                                    let update = ["Likes" : String(count)]
                                    let userAnswerUid = properties["Uid"] as? String
                                    ref.child(self.questionID).child(self.answerID).updateChildValues(update)
                                    self.updateMyLike(userid: userAnswerUid!)
                                    self.likeButtonOutlet.isHidden = true
                                    self.likeButtonOutlet.isEnabled = true
                                    self.likedButtonOutlet.isHidden = false


                                }
                            }
                        })
                    }
                })
            }
            }
        ref.removeAllObservers()
    
        }
    
    func updateMyLike(userid:String){
        let userDB = Database.database().reference().child("Users").child(userid).child("AnswerLikes")
        
        userDB.keepSynced(true)
        userDB.observeSingleEvent(of: .value) { (snapshot) in
            if let answerLikes = snapshot.value as? String{
                var answerLikesInt = Int(answerLikes)
                answerLikesInt! += 1
                userDB.setValue(String(answerLikesInt!))
            }
        }
    }
    
    func updateMyLikeDown(userid:String){
        let userDB = Database.database().reference().child("Users").child(userid).child("AnswerLikes")
        
        userDB.keepSynced(true)
        userDB.observeSingleEvent(of: .value) { (snapshot) in
            if let answerLikes = snapshot.value as? String{
                var answerLikesInt = Int(answerLikes)
                answerLikesInt! -= 1
                userDB.setValue(String(answerLikesInt!))
                print("CALLED")
            }
        }
    }
    
    

    
    
    @IBAction func likedButtonPressed(_ sender: Any) {
        
        self.likedButtonOutlet.isEnabled = false
        let ref = Database.database().reference().child("Answers")
        
        ref.child(questionID).child(answerID).observeSingleEvent(of: .value) { (snapshot) in
            if let properties = snapshot.value as? [String : AnyObject]{
                if let peopleWhoLike = properties["peopleWhoLike"] as? [String : AnyObject] {
                    for (id, _) in peopleWhoLike {
                        if id == self.userID{
                            self.updateMyLikeDown(userid: id)
                            ref.child(self.questionID).child(self.answerID).child("peopleWhoLike").child(id).removeValue(completionBlock: { (error, reference) in
                                if error != nil {
                                    print(error!)
                                } else {
                                    self.cellDelegate?.updateAnswerArrayDelegate(index: self.answerIndex, userID: self.userID!, isAdd: false)
                                    let ref = Database.database().reference().child("Answers")
                                    ref.child(self.questionID).child(self.answerID).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let prop = snapshot.value as? [String : AnyObject] {
                                            if let likes = prop["peopleWhoLike"] as? [String : AnyObject] {
                                                let count = likes.count
                                                self.numberofLikes.text = "\(count) likes"
                                                let update = ["Likes" : String(count)]
                                                let userAnswerUid = prop["Uid"] as? String
                                                ref.child(self.questionID).child(self.answerID).updateChildValues(update)
                                                self.updateMyLikeDown(userid: userAnswerUid!)
                                            } else{
                                                self.numberofLikes.text = "0 likes"
                                                ref.child(self.questionID).child(self.answerID).updateChildValues(["Likes" : "0"]   )
                                                
                                            }
                                        }
                                    })
                                }
                            })
                        }
                        self.likeButtonOutlet.isHidden = false
                        self.likedButtonOutlet.isHidden = true
                        self.likedButtonOutlet.isEnabled = true
                        break
                    }
                }
            }
        }
        ref.removeAllObservers()
    }

}
