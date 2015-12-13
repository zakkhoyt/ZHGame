//
//  ViewController.swift
//  ZHGameTVOS
//
//  Created by Zakk Hoyt on 12/12/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var clientsLabel: UILabel!
    var clients = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusLabel.text = "Waiting"
        clientsLabel.text = ""
        
        BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data: String) in
            NSLog("\(data)")
            self.clients.append(data)
            
            self.clientsLabel.text = data + "\n" + self.clientsLabel.text!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

