//
//  BonjourTCPClient.swift
//  BonjourTCP
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation



class BonjourTCPClient : NSObject {
	
//	let kServiceType = "_myservice._tcp."
//    let kServiceType = "_vaporwarewolf_service._tcp."
    let kServiceType = ZHBonjourServiceName
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	static let sharedInstance = BonjourTCPClient()
	
	private override init() {
		super.init()

		self.startBrowsingServices()
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: service browser
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	var serviceBrowser : NSNetServiceBrowser? = nil
	var services : [NSNetService] = []
	var servicesCallback : (([NSNetService]) ->())? = nil
	
	var streamsConnected = false
	var streamsConnectedCallback : (Void -> Void)?
	
	func startBrowsingServices() {
		self.serviceBrowser = NSNetServiceBrowser()
		self.serviceBrowser?.includesPeerToPeer = true
		self.serviceBrowser?.delegate = self
		self.serviceBrowser?.searchForServicesOfType(kServiceType, inDomain: "local")
	}
	


	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: connect to service
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func connectTo(service: NSNetService, callback: (Void -> Void)?) {
		self.streamsConnectedCallback = callback

		var inputStream : NSInputStream? = nil
		var outputStream : NSOutputStream? = nil
		
		let success = service.getInputStream(&inputStream, outputStream: &outputStream)
		
		if !success {
			return NSLog("could not connect to service")
		}
		self.inputStream  = inputStream
		self.outputStream = outputStream
		
		self.openStreams()

		NSLog("connecting...")
	}
	
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: send message
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    func send(message: String) {
        guard self.openedStreams == 2 else {
            return NSLog("no open streams \(self.openedStreams)")
        }
        
        guard self.outputStream!.hasSpaceAvailable else {
            return NSLog("no space available")
        }
        
        let data: NSData = message.dataUsingEncoding(NSUTF8StringEncoding)!
        let bytesWritten = self.outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
        guard bytesWritten == data.length else {
            self.closeStreams()
            return NSLog("something is wrong...")
        }
        NSLog("data written... \(message)")
    }
    
    
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: streams
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	
	var inputStream : NSInputStream? = nil
	var outputStream : NSOutputStream? = nil
	var openedStreams : Int = 0
	
	
	func openStreams() {
		guard self.openedStreams == 0 else {
			return NSLog("streams already opened... \(self.openedStreams)")
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

		self.streamsConnected = false
		self.openedStreams = 0
	}
	
	



	

    
	
	
}

extension BonjourTCPClient: NSNetServiceBrowserDelegate {
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: browser delegate
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {}
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {}
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {}
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {}
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {}
    
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        NSLog("service found:" + service.name)
        self.services.append(service)
        
        if !moreComing {
            if let callback = self.servicesCallback {
                callback(self.services)
            }
        }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        NSLog("service removed:" + service.name)
        self.services = self.services.filter() { $0 != service }
        
        if !moreComing {
            if let callback = self.servicesCallback {
                callback(self.services)
            }
        }
    }
}

extension BonjourTCPClient: NSStreamDelegate {
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            self.openedStreams++
            
            break
        case NSStreamEvent.HasSpaceAvailable:
            if self.openedStreams == 2 && !self.streamsConnected {
                NSLog("streams connected.")
                self.streamsConnected = true
                self.streamsConnectedCallback?()
            }
            break
        default:
            break
        }
    }
}


//extension BonjourTCPClient: NSNetServiceDelegate {
//    ///////////////////////////////////////////////////////////////////////////////////////////////////
//    //  MARK: NSStreamDelegate
//    ///////////////////////////////////////////////////////////////////////////////////////////////////
//    
//    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
//        
////        switch eventCode {
////        case NSStreamEvent.None:
////            
////            break
////        case NSStreamEvent.OpenCompleted:
////            self.openedStreams++
////            
////            if self.openedStreams == 2 {
////                self.service?.stop()
////                self.serviceRunning = false
////                self.registeredName = nil
////            }
////            break
////        case NSStreamEvent.HasBytesAvailable:
////            guard let inputStream = self.inputStream else {
////                return NSLog("no input stream")
////            }
////            
////            let bufferSize     = 4096
////            var buffer         = Array<UInt8>(count: bufferSize, repeatedValue: 0)
////            var message        = ""
////            
////            while inputStream.hasBytesAvailable {
////                let len = inputStream.read(&buffer, maxLength: bufferSize)
////                if len < 0 {
////                    NSLog("error reading stream...")
////                    return self.closeStreams()
////                }
////                if len > 0 {
////                    message += NSString(bytes: &buffer, length: len, encoding: NSUTF8StringEncoding) as! String
////                }
////                if len == 0 {
////                    NSLog("no more bytes available...")
////                    break
////                }
////            }
////            self.dataReceivedCallback?(message)
////            break
////            
////        default:
////            break
////        }
//    }
//}







