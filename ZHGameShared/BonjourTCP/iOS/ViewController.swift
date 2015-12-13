//
//  ViewController.swift
//  BonjourTCP
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
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

