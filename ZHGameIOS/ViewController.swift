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
    
    @IBOutlet weak var clientButton: UIButton!
    @IBOutlet weak var clientView: UIView!
    @IBOutlet weak var clientUsernameTextField: UITextField!
    @IBOutlet weak var clientUUIDTextField: UITextField!
    @IBOutlet weak var clientSendMessageTextField: UITextField!
    @IBOutlet weak var clientSendButton: UIButton!
    @IBOutlet weak var clientReceiveTextView: UITextView!
    
    @IBOutlet weak var serverButton: UIButton!
    @IBOutlet weak var serverView: UIView!
    @IBOutlet weak var serverSendMessageTextField: UITextField!
    @IBOutlet weak var serverSendButton: UIButton!
    @IBOutlet weak var serverReceiveTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        serverView.hidden = true
        clientView.hidden = true
        
        uuidTextField.text = NSUUID().UUIDString
        usernameTextField.text = "zakk_6+"
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func serverButtonTouchUpInside(sender: UIButton!) {
        serverView.hidden = false
        serverButton.hidden = true
        clientButton.hidden = true
    }
    
    func appendClientReceive(message: String) {
        clientReceiveTextView.text = message + "\n" + serverReceiveTextView.text
        print(message)
    }
    
    @IBAction func clientButtonTouchUpInside(sender: UIButton!) {
        clientView.hidden = false
        serverButton.hidden = true
        clientButton.hidden = true

//        // Find services (servers)
//        self.appendClientReceive("Beginning search for services...")
//        BonjourTCPClient.sharedInstance.servicesCallback = { (services) in
//            guard let service = services.first else {
//                self.appendClientReceive("No services available")
//                return
//            }
//            
//            self.appendClientReceive("Connecting to: \(service.name)")
//
//            
//            // Connect to server
//            BonjourTCPClient.sharedInstance.connectTo(service, callback: {
//                let user = ZHUser()
//                user.uuid = self.uuidTextField.text
//                user.username = self.usernameTextField.text
//                let userJSON = user.jsonRepresentation()
//                if let userJSON = userJSON  {
//                    // Send message to server
//                    BonjourTCPClient.sharedInstance.send(userJSON)
//                } else {
//                    self.appendClientReceive("Can't sent JSON string: ")
//                }
//            })
//        }
        
        // Find services (servers)
        self.appendClientReceive("Beginning search for services...")
        ZHBonjour.sharedInstance.servicesCallback = { (services) in
            guard let service = services.first else {
                self.appendClientReceive("No services available")
                return
            }
            
            self.appendClientReceive("Connecting to: \(service.name)")
            
            
            // Connect to server
            ZHBonjour.sharedInstance.connectTo(service, callback: {
                let user = ZHUser()
                user.uuid = self.uuidTextField.text
                user.username = self.usernameTextField.text
                let userJSON = user.jsonRepresentation()
                if let userJSON = userJSON  {
                    // Send message to server
                    ZHBonjour.sharedInstance.send(userJSON)
                } else {
                    self.appendClientReceive("Can't sent JSON string: ")
                }
            })
        }
        ZHBonjour.sharedInstance.dataReceivedCallback = {(data: String) in
            self.appendClientReceive(data)
        }

        
        ZHBonjour.sharedInstance.startClient()
        

    }

}

