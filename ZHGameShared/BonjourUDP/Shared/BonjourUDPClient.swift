//
//  Client.swift
//  Impixable
//
//  Created by Tibor Bodecs on 2015. 09. 29..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation
import CocoaAsyncSocket


#if os(OSX)
	private let deviceName = NSHost.currentHost().localizedName!
#else
	import UIKit
	private let deviceName = UIDevice.currentDevice().name
#endif


class BonjourUDPClient : NSObject, NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncUdpSocketDelegate
{
		
	let socket = GCDAsyncUdpSocket()
	let socketPort: UInt16 = 5566

	var hostName : String?
	
	let serviceDomain = "local"
	let serviceType = "_udp_discovery._udp."
	var serviceBrowser : NSNetServiceBrowser? = nil
	var services : [NSNetService] = []
	var servicesCallback : (([NSNetService]) ->())? = nil
	
	var resolved = false
	var resolvedCallback: (Void -> Void)? = nil

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

	static let sharedInstance = BonjourUDPClient()

	private override init() {
		super.init()

		self.serviceBrowser = NSNetServiceBrowser()
		self.serviceBrowser?.delegate = self
		self.serviceBrowser?.searchForServicesOfType(serviceType, inDomain: self.serviceDomain)
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: NSNetServiceDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func netServiceDidResolveAddress(sender: NSNetService) {
		guard let host = sender.hostName else {
			return NSLog("could not resolve host")
		}
		self.hostName = host

		NSLog("resolved host: \(self.hostName!)")

		if !self.resolved {
			self.resolved = true
			self.resolvedCallback?()
		}
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: message sending API
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func send(message: String) {
		if let host = self.hostName {
			let data = message.dataUsingEncoding(NSUTF8StringEncoding)
			self.socket.sendData(data, toHost: host, port: self.socketPort, withTimeout: -1, tag: 0)
		}
		else {
			NSLog("no hosts resolved!")
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: NSNetServiceBrowserDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {}
	func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {}
	func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {}
	func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {}
	func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {}
	

	func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
		NSLog("found:" + service.name)
		
		self.services.append(service)
		
		if !moreComing {
			if let callback = self.servicesCallback {
				callback(self.services)
			}
		}
	}

	func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
		NSLog("removed:" + service.name)
		
		self.services = self.services.filter() { $0 != service }
		
		if !moreComing {
			if let callback = self.servicesCallback {
				callback(self.services)
			}
		}
	}
	
	
}

