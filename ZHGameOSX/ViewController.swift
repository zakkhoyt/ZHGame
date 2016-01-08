//
//  ViewController.swift
//  ZHGameOSX
//
//  Created by Zakk Hoyt on 1/7/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Cocoa
//import BonjourTCPServer

class ViewController: NSViewController {

    
    @IBOutlet var clientsTextView: NSTextView!
    @IBOutlet var serverReceiveTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data: String) in
            
            // If user, parse. If not display
            let user: ZHUser? = ZHUser(jsonString: data)
            if let user = user {
                self.appendServerReceive("received: " + user.description)
            } else {
                self.appendServerReceive("received: " + data)
            }
            
            // Send reply
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.appendServerReceive("sending: echo " + data)
                BonjourTCPServer.sharedInstance.send("sending: echo " + data)
            }
        }
    }
    
    func appendServerReceive(message: String) {
        self.clientsTextView.string = "*** " +  message + "\n" + self.clientsTextView.string!
        print(message)
    }



}

