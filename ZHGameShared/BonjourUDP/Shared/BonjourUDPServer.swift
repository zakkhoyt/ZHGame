//
//  Server.swift
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


class BonjourUDPServer: NSObject, GCDAsyncUdpSocketDelegate, NSNetServiceDelegate
{

	var socket : GCDAsyncUdpSocket!
	let socketPort: UInt16 = 5566

	var service : NSNetService? = nil
	let servicePort : Int32 = 5667
	let serviceDomain = "local."
	let serviceType = "_udp_discovery._udp."
	
	var registeredName : String? = nil
	
	var callback : ((message: String, from: String) -> Void)?

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

	static let sharedInstance = BonjourUDPServer()
	
	private override init() {
		super.init()

		self.service = NSNetService(domain: self.serviceDomain, type: self.serviceType, name: deviceName, port: self.servicePort)
		self.service?.delegate = self
		self.service?.publish()

		self.socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
		let _ = try? self.socket.bindToPort(self.socketPort)
		let _ = try? self.socket.beginReceiving()
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: NSNetServiceDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func netServiceWillPublish(sender: NSNetService) {}
	
	func netServiceDidPublish(sender: NSNetService) {
		self.registeredName = sender.name
		NSLog("registered \(sender.name)")
	}
	
	func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {
		NSLog("service error \(errorDict)")
	}

	func netServiceWillResolve(sender: NSNetService) {}
	func netServiceDidResolveAddress(sender: NSNetService) {}
	func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {}
	func netServiceDidStop(sender: NSNetService) {}
	func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {}
	func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: socket delegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func udpSocket(sock: GCDAsyncUdpSocket!, didReceiveData data: NSData!,
		fromAddress address: NSData!, withFilterContext filterContext: AnyObject!)
	{
		let address    = GCDAsyncUdpSocket.hostFromAddress(address)
		let dataString = String(data: data, encoding: NSUTF8StringEncoding)

		if
			let message = dataString
		{
			self.callback?(message: message, from: address)
		}
	}
	
	
}

