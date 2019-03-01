//
//  TabBarViewController.swift
//  Circle
//
//  Created by Frank Chen on 2018-10-25.
//  Copyright © 2018 Frank Chen. All rights reserved.
//

import UIKit
import CoreLocation


class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self

        // Do any additional setup after loading the vieww
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (tabBar.items)![3]{
        item.badgeValue = nil
        }
    }
}
    
