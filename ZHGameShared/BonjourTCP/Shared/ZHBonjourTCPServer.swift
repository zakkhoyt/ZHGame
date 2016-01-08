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


class BonjourTCPServer : NSObject {


    var dataReceivedCallback : ((String) -> ())? = nil

	static let sharedInstance = BonjourTCPServer()
	
	private override init() {
		super.init()
		
		service = NSNetService(domain: "local.", type: ZHBonjourTCPServiceName, name: deviceName, port: 0)
		service?.includesPeerToPeer = true
		service?.delegate = self
		service?.publishWithOptions(.ListenForConnections)
		
		serviceRunning = true
		
	}
    
    deinit {
        print("Servier deinit")
    }
	
	var service : NSNetService? = nil
	var serviceRunning = false
	var registeredName : String? = nil

	var inputStream : NSInputStream? = nil
	var outputStream : NSOutputStream? = nil
	var openedStreams : Int = 0


	func openStreams() {
		guard openedStreams == 0 else {
			return
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
		
		openedStreams = 0
	}
    
    func send(message: String) {
        guard openedStreams == 2 else {
            return print("no open streams \(self.openedStreams)")
        }
        
        guard outputStream!.hasSpaceAvailable else {
            return print("no space available")
        }
        
        let data: NSData = message.dataUsingEncoding(NSUTF8StringEncoding)!
        let bytesWritten = self.outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
        guard bytesWritten == data.length else {
            closeStreams()
            return print("something is wrong...")
        }
        print("data written... \(message)")
    }
}


extension BonjourTCPServer: NSNetServiceDelegate {
    
    func netServiceWillPublish(sender: NSNetService) {}
    func netServiceDidPublish(sender: NSNetService) {
        registeredName = sender.name
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
                return print("connection already open.")
            }
            self?.service?.stop()
            self?.serviceRunning = false
            self?.registeredName = nil
            
            self?.inputStream = inputStream
            self?.outputStream = outputStream
            
            self?.openStreams()
            
            print("connection accepted: streams opened.")
        }
    }

}

extension BonjourTCPServer: NSStreamDelegate {
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode {
        case NSStreamEvent.None:
            print("None")
            
        case NSStreamEvent.OpenCompleted:
            print("OpenCompleted")
            self.openedStreams++
            if self.openedStreams == 2 {
                self.service?.stop()
                self.serviceRunning = false
                self.registeredName = nil
            }
            
        case NSStreamEvent.HasBytesAvailable:
            print("HasBytesAvailable")
            guard let inputStream = self.inputStream else {
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
            print("HasSpaceAvailable")
            
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred")
            
        case NSStreamEvent.EndEncountered:
            print("EndEncountered")
            
        default:
            break
        }
    }
}








