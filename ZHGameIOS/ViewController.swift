//
//  ViewController.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 12/12/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let testData = "My test data string"
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var uuidTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        uuidTextField.text = NSUUID().UUIDString
        usernameTextField.text = "zakk_6+"
        
        
        BonjourTCPClient.sharedInstance.servicesCallback = { (services) in
            guard let service = services.first else {
                return NSLog("no services...")
            }
            
            NSLog("connecting to: \(service.name)")
            
            BonjourTCPClient.sharedInstance.connectTo(service, callback: {
                let user = ZHUser()
                user.uuid = self.uuidTextField.text
                user.username = self.usernameTextField.text
                if let userJSON = user.jsonRepresentation() {
                    BonjourTCPClient.sharedInstance.send(userJSON)
                } else {
                    print("Can't sent JSON string because it is nil")
                }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

