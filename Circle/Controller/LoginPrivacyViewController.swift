//
//  LoginPrivacyViewController.swift
//  Circle
//
//  Created by Frank Chen on 2019-03-01.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit

class LoginPrivacyViewController: UIViewController, UIWebViewDelegate {

    let urlString = "https://bit.ly/2SSoXSp"
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        webView.backgroundColor = UIColor.white
        
        loadPrivacy()
        
    }
    
    func loadPrivacy(){
        if let url = URL(string: urlString){
            let urlRequest = URLRequest(url: url)
            webView.loadRequest(urlRequest)
        }
    }
}
