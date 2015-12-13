//
//  ViewController.swift
//  BonjourUDP
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		BonjourUDPClient.sharedInstance.servicesCallback = { (services) in
			if let service = services.first {
				service.delegate = BonjourUDPClient.sharedInstance
				service.resolveWithTimeout(0)
			}
			
			
		}

		BonjourUDPClient.sharedInstance.resolvedCallback = {
			BonjourUDPClient.sharedInstance.send("Maecenas faucibus mollis interdum.")
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

