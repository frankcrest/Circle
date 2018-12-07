//
//  DesignerSlider.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-26.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit

@IBDesignable
class DesignerSlider: UISlider {
    @IBInspectable var thumbImage: UIImage? {
        didSet{
            setThumbImage(thumbImage, for: .normal)
        }
    }

}
