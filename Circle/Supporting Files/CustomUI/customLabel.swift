//
//  customLabel.swift
//  Circle
//
//  Created by Frank Chen on 2018-11-19.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.size.height / 3
        layer.masksToBounds = true
    }
    
    let inset = UIEdgeInsets(top: 5, left: 10, bottom: 5,  right: 10)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        var intrinsicContentSize = super.intrinsicContentSize
        intrinsicContentSize.width += inset.left + inset.right
        intrinsicContentSize.height += inset.top + inset.bottom
        return intrinsicContentSize
    }
    
}
