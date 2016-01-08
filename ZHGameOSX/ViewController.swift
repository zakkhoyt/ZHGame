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

//        BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data: String) in
//            print("Received: \(data)")
//            let user = ZHUser(jsonString: data)
//            self.appendServerReceive("sent user data: \n" + user.description)
//
////            self.users.append(user)
////            self.collectionView.reloadData()
//            
////            BonjourTCPServer.sharedInstance.send("Closed loop");
//        }
        
        ZHBonjour.sharedInstance.dataReceivedCallback = {(data: String) in
            print("Received: \(data)")
            let user: ZHUser? = ZHUser(jsonString: data)
            if let user = user {
                self.appendServerReceive("received user data: \n" + user.description)
            } else {
                self.appendServerReceive(data)
            }
            
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.appendServerReceive("received: " + data)
                self.appendServerReceive("sending: echo " + data)
                ZHBonjour.sharedInstance.send("sending: echo " + data)
            }
        }
        
        ZHBonjour.sharedInstance.startServer()
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    func appendServerReceive(message: String) {
        self.clientsTextView.string = "*** " +  message + "\n" + self.clientsTextView.string!
        print(message)
    }



}

