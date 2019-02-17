//
//  customSettingsCell.swift
//  Circle
//
//  Created by Frank Chen on 2018-12-09.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit

class customSettingsCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
