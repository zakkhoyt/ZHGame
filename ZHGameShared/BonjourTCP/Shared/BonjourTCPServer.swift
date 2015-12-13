//
//  BonjourTCP.swift
//  BonjourTCP
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//


import Foundation


#if os(OSX)
	private let deviceName = NSHost.currentHost().localizedName!
#else
	import UIKit
	private let deviceName = UIDevice.currentDevice().name
#endif


class BonjourTCPServer : NSObject, NSNetServiceDelegate, NSStreamDelegate
{

	let kWiTapBonjourType = "_myservice._tcp."

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

	static let sharedInstance = BonjourTCPServer()
	
	private override init() {
		super.init()
		
		self.service = NSNetService(domain: "local.", type: kWiTapBonjourType, name: deviceName, port: 0)
		self.service?.includesPeerToPeer = true
		self.service?.delegate = self
		self.service?.publishWithOptions(.ListenForConnections)
		
		self.serviceRunning = true
		
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: service
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	var service : NSNetService? = nil
	var serviceRunning = false
	var registeredName : String? = nil

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: NSNetServiceDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////

	
	func netServiceWillPublish(sender: NSNetService) {}
	func netServiceDidPublish(sender: NSNetService) {
		self.registeredName = sender.name
	}
	
	func netService(sender: NSNetService, didNotPublish errorDict: [String : NSNumber]) {}
	func netServiceWillResolve(sender: NSNetService) {}
	func netServiceDidResolveAddress(sender: NSNetService) {}
	func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {}
	func netServiceDidStop(sender: NSNetService) {}
	func netService(sender: NSNetService, didUpdateTXTRecordData data: NSData) {}
	

	func netService(sender: NSNetService, didAcceptConnectionWithInputStream inputStream: NSInputStream, outputStream: NSOutputStream) {
		NSOperationQueue.mainQueue().addOperationWithBlock { [weak self] in
			if self?.inputStream != nil {
				inputStream.open()
				inputStream.close()
				outputStream.open()
				outputStream.close()
				return NSLog("connection already open.")
			}
			self?.service?.stop()
			self?.serviceRunning = false
			self?.registeredName = nil
			
			self?.inputStream = inputStream
			self?.outputStream = outputStream
			
			self?.openStreams()
			
			NSLog("connection accepted: streams opened.")
		}
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: streams
	///////////////////////////////////////////////////////////////////////////////////////////////////

	
	var inputStream : NSInputStream? = nil
	var outputStream : NSOutputStream? = nil
	var openedStreams : Int = 0


	func openStreams() {
		guard self.openedStreams == 0 else {
			return
		}

		self.inputStream?.delegate = self
		self.inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		self.inputStream?.open()
		
		self.outputStream?.delegate = self
		self.outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		self.outputStream?.open()
	}


	func closeStreams() {
		self.inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		self.inputStream?.close()
		self.inputStream = nil
		
		self.outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		self.outputStream?.close()
		self.outputStream = nil
		
		self.openedStreams = 0
	}
	
	

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: nsstream delegate
	///////////////////////////////////////////////////////////////////////////////////////////////////

	var dataReceivedCallback : ((String) -> ())? = nil
	func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {

		switch eventCode {
		case NSStreamEvent.None:

		break
		case NSStreamEvent.OpenCompleted:
			self.openedStreams++
			
			if self.openedStreams == 2 {
				self.service?.stop()
				self.serviceRunning = false
				self.registeredName = nil
			}
		break
		case NSStreamEvent.HasBytesAvailable:
			guard let inputStream = self.inputStream else {
				return NSLog("no input stream")
			}
			
			let bufferSize     = 4096
			var buffer         = Array<UInt8>(count: bufferSize, repeatedValue: 0)
			var message        = ""

			while inputStream.hasBytesAvailable {
				let len = inputStream.read(&buffer, maxLength: bufferSize)
				if len < 0 {
					NSLog("error reading stream...")
					return self.closeStreams()
				}
				if len > 0 {
					message += NSString(bytes: &buffer, length: len, encoding: NSUTF8StringEncoding) as! String
				}
				if len == 0 {
					NSLog("no more bytes available...")
					break
				}
			}
			self.dataReceivedCallback?(message)
		break

		default:
		break
		}
	}

}










