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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        BonjourTCPClient.sharedInstance.servicesCallback = { (services) in
            guard let service = services.first else {
                return NSLog("no services...")
            }
            
            NSLog("connecting to: \(service.name)")
            
            BonjourTCPClient.sharedInstance.connectTo(service, callback: {
                BonjourTCPClient.sharedInstance.send(self.testData)
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

