//
//  ViewController.swift
//  ZHGameTVOS
//
//  Created by Zakk Hoyt on 12/12/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data) in
            NSLog("\(data)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
