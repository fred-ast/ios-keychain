//
//  ViewController.swift
//  ios-Keychain
//
//  Created by Frédéric ASTIC on 09/08/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        KeychainManager.set("my-securized-email", key: .email)
        
    }
}

