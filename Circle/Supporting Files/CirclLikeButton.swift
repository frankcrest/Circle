//
//  CirclLikeButton.swift
//  Circle
//
//  Created by Frank Chen on 2018-11-04.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import Firebase

class CirclLikeButton: UIButton{
    
    var IsOn = false
    
    override init(frame: CGRect){
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }

    func initButton (){
        let origImage = UIImage(named: "heart")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        setImage(tintedImage, for: .normal)
        addTarget(self, action: #selector(CirclLikeButton.buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed () {
       // activateButton(bool: !IsOn)
        
    }
    
    func activateButton (bool: Bool) {
        IsOn = bool
        if bool == true {
            setImage(UIImage(named: "liked"), for: .normal)
        } else {
            setImage(UIImage(named: "heart"), for: .normal)
        }
        
    }
    


    
}

