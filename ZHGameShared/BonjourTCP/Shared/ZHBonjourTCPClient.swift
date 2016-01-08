//
//  BonjourTCPClient.swift
//  BonjourTCP
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation

class BonjourTCPClient : NSObject {
	
	static let sharedInstance = BonjourTCPClient()
	
    var dataReceivedCallback : ((String) -> ())? = nil
    
	private override init() {
		super.init()
		startBrowsingServices()
	}
    
    deinit {
        print("Client deinit")
    }

	
	var serviceBrowser : NSNetServiceBrowser? = nil
	var services : [NSNetService] = []
	var servicesCallback : (([NSNetService]) ->())? = nil
	
	var streamsConnected = false
	var streamsConnectedCallback : (Void -> Void)?
	
	func startBrowsingServices() {
		serviceBrowser = NSNetServiceBrowser()
		serviceBrowser?.includesPeerToPeer = true
		serviceBrowser?.delegate = self
		serviceBrowser?.searchForServicesOfType(ZHBonjourTCPServiceName, inDomain: "local")
	}
	

	func connectTo(service: NSNetService, callback: (Void -> Void)?) {
		streamsConnectedCallback = callback

		var inputStream : NSInputStream? = nil
		var outputStream : NSOutputStream? = nil
		
		let success = service.getInputStream(&inputStream, outputStream: &outputStream)
		
		if !success {
			return print("could not connect to service")
		}
		self.inputStream  = inputStream
		self.outputStream = outputStream
		
		openStreams()

		print("connecting...")
	}
	
    func send(message: String) {
        guard openedStreams == 2 else {
            return print("no open streams \(openedStreams)")
        }
        
        guard outputStream!.hasSpaceAvailable else {
            return print("no space available")
        }
        
        let data: NSData = message.dataUsingEncoding(NSUTF8StringEncoding)!
        let bytesWritten = outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
        guard bytesWritten == data.length else {
            closeStreams()
            return print("something is wrong...")
        }
        print("data written... \(message)")
    }
    
	var inputStream : NSInputStream? = nil
	var outputStream : NSOutputStream? = nil
	var openedStreams : Int = 0
	
	
	func openStreams() {
		guard openedStreams == 0 else {
			return print("streams already opened... \(self.openedStreams)")
		}
		
		inputStream?.delegate = self
		inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		inputStream?.open()
		
		outputStream?.delegate = self
		outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		outputStream?.open()
	}
	
	
	func closeStreams() {
		inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		inputStream?.close()
		inputStream = nil
		
		outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		outputStream?.close()
		outputStream = nil

		streamsConnected = false
		openedStreams = 0
	}
}

extension BonjourTCPClient: NSNetServiceBrowserDelegate {
    func netServiceBrowserWillSearch(browser: NSNetServiceBrowser) {}
    func netServiceBrowserDidStopSearch(browser: NSNetServiceBrowser) {}
    func netServiceBrowser(browser: NSNetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {}
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindDomain domainString: String, moreComing: Bool) {}
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveDomain domainString: String, moreComing: Bool) {}
    
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        print("service found:" + service.name)
        services.append(service)
        
        if !moreComing {
            if let callback = servicesCallback {
                callback(services)
            }
        }
    }
    
    func netServiceBrowser(browser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        print("service removed:" + service.name)
//        self.services = self.services.filter() { $0 != service }
//        
//        if !moreComing {
//            if let callback = self.servicesCallback {
//                callback(self.services)
//            }
//        }
    }
}

extension BonjourTCPClient: NSStreamDelegate {
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.None:
            print("None")

        case NSStreamEvent.OpenCompleted:
            openedStreams++
            
        case NSStreamEvent.HasBytesAvailable:
            print("HasBytesAvailable")
            guard let inputStream = inputStream else {
                return print("no input stream")
            }
            
            let bufferSize     = 4096
            var buffer         = Array<UInt8>(count: bufferSize, repeatedValue: 0)
            var message        = ""
            
            while inputStream.hasBytesAvailable {
                let len = inputStream.read(&buffer, maxLength: bufferSize)
                if len < 0 {
                    print("error reading stream...")
                    return self.closeStreams()
                }
                
                if len > 0 {
                    message += NSString(bytes: &buffer, length: len, encoding: NSUTF8StringEncoding) as! String
                }
                
                if len == 0 {
                    print("no more bytes available...")
                    break
                }
            }
            self.dataReceivedCallback?(message)

        case NSStreamEvent.HasSpaceAvailable:
            if self.openedStreams == 2 && !self.streamsConnected {
                print("streams connected.")
                self.streamsConnected = true
                self.streamsConnectedCallback?()
            }
            
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred")
            
        case NSStreamEvent.EndEncountered:
            print("EndEncountered")

        default:
            break
        }
    }
}




