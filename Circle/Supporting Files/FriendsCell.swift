//
//  FriendsCell.swift
//  Circle
//
//  Created by Frank Chen on 2018-12-05.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendMessage: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
