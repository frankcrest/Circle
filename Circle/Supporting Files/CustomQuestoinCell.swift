//
//  CustomQuestoinCell.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-27.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit

class CustomQuestoinCell: UITableViewCell {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var coinLabel: UIButton!
    @IBOutlet weak var separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .gray
        // Initialization code
    }



}
