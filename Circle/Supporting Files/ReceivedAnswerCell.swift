//
//  ReceivedAnswerCell.swift
//  Circle
//
//  Created by Frank Chen on 2018-11-07.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

protocol UpdateCheckedDelegate : class {
    func updateCheckedDelegate(index: Int, userID: String, isAdd: Bool)
}

class ReceivedAnswerCell: UITableViewCell {
    weak var cellDelegate : UpdateCheckedDelegate?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var answerText: UILabel!
    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var answerCheckMark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        answerCheckMark.tintColor = UIColor.lightGray
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        answerCheckMark.tintColor = UIColor.lightGray
    }
    
    var questionID : String!
    var answerID : String!
    var answerIndex : Int!
    var userID = Auth.auth().currentUser?.uid
    
    
    @IBAction func checkPressed(_ sender: Any) {
        if answerCheckMark.tintColor == UIColor.lightGray {
        answerCheckMark.isEnabled = false
        
        let ref = Database.database().reference().child("Answers")
        ref.child(questionID).observeSingleEvent(of: .value) { (snapshot) in
            
            let enumerator = snapshot.children
                
            while let rest = enumerator.nextObject() as? DataSnapshot{
                let key = rest.key
                var keys = [String]()
                keys.append(key)
    
                for key in keys{
                    ref.child(self.questionID).child(key).child("CheckedBy").removeValue()
                }
                
                let updateChecked : [String : String] = ["CheckedBy" : self.userID!]
                ref.child(self.questionID).child(self.answerID).updateChildValues(updateChecked,withCompletionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                        } else {
                        self.cellDelegate?.updateCheckedDelegate(index: self.answerIndex, userID: self.userID!, isAdd: true)
                        self.answerCheckMark.isEnabled = true
                        self.answerCheckMark.tintColor = self.hexStringToUIColor(hex: "#FF7878")
                                }
                            })
                        }
            }
        ref.removeAllObservers()
        } else {
            answerCheckMark.isEnabled = false
            let ref = Database.database().reference().child("Answers")
            ref.child(questionID).child(answerID).observeSingleEvent(of: .value) { (snapshot) in
                if let _ = snapshot.value as? [String : AnyObject] {
                    //let updateChecked : [String : String] = ["CheckedBy" : self.userID!]
                    ref.child(self.questionID).child(self.answerID).child("CheckedBy").removeValue(completionBlock: { (error, ref) in
                        if error != nil {
                            print(error!)
                        }
                        else {
                            self.cellDelegate?.updateCheckedDelegate(index: self.answerIndex, userID: self.userID!, isAdd: false)
                            self.answerCheckMark.tintColor = UIColor.lightGray
                            self.answerCheckMark.isEnabled = true
                        }
                    })
                }
            }
            ref.removeAllObservers()
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
