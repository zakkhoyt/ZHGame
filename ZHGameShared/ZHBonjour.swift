//
//  ZHBonjour.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 1/7/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Foundation

#if os(OSX)
    private let deviceName = NSHost.currentHost().localizedName!
#else
    import UIKit
    private let deviceName = UIDevice.currentDevice().name
#endif



class ZHBonjour : NSObject {
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //  MARK: init
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    
    static let sharedInstance = ZHBonjour()
    
    private override init() {
        super.init()
        
        service = NSNetService(domain: "local.", type: kWiTapBonjourType, name: deviceName, port: 0)
        service?.includesPeerToPeer = true
        service?.delegate = self
        
    }
    
    deinit {
        print("deinit")
    }

    // Constants
    private let kWiTapBonjourType = ZHBonjourServiceName
    
    // NSNetService stuff
    private var service : NSNetService? = nil
    private var serviceRunning = false
    private var registeredName : String? = nil

    // Stream stuff
    private var inputStream : NSInputStream? = nil
    private var outputStream : NSOutputStream? = nil
    private var openedStreams : Int = 0
    
    // Callbacks
    var dataReceivedCallback : ((String) -> ())? = nil
    
    

    
    private func openStreams() {
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
    
    
    private func closeStreams() {
        inputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        inputStream?.close()
        inputStream = nil
        
        outputStream?.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        outputStream?.close()
        outputStream = nil
        
        openedStreams = 0
    }
    
    
    func startServer() {
        self.service?.publishWithOptions(.ListenForConnections)
        self.serviceRunning = true
        
    }
    
    func stopServer() {
        self.service?.stop()
        self.serviceRunning = false
    }
    
    
    private var serviceBrowser : NSNetServiceBrowser? = nil
    private var services : [NSNetService] = []
    var servicesCallback : (([NSNetService]) ->())? = nil
    
    private var streamsConnected = false
    private var streamsConnectedCallback : (Void -> Void)?

    private func startBrowsingServices() {
        self.serviceBrowser = NSNetServiceBrowser()
        self.serviceBrowser?.includesPeerToPeer = true
        self.serviceBrowser?.delegate = self
        self.serviceBrowser?.searchForServicesOfType(kWiTapBonjourType, inDomain: "local")
    }
    
    
    
    func startClient() {
        self.startBrowsingServices()
    }
    
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
    
    func send(message: String) {
        guard self.openedStreams == 2 else {
            return NSLog("no open streams \(self.openedStreams)")
        }
        
        guard self.outputStream!.hasSpaceAvailable else {
            return NSLog("no space available")
        }
        
        while self.outputStream!.hasSpaceAvailable == false {
            print("wasting time")
        }
        
        let data: NSData = message.dataUsingEncoding(NSUTF8StringEncoding)!
        let bytesWritten = self.outputStream!.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
        guard bytesWritten == data.length else {
            self.closeStreams()
            return NSLog("something is wrong...")
        }
        NSLog("data written... \(message)")
    }

}


extension ZHBonjour: NSNetServiceDelegate {
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
}


extension ZHBonjour: NSStreamDelegate {
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        
        switch eventCode {
        case NSStreamEvent.None:
            print("None")
            break
        case NSStreamEvent.OpenCompleted:
            print("OpenCompleted")
            self.openedStreams++
            
            if self.openedStreams == 2 {
                self.service?.stop()
                self.serviceRunning = false
                self.registeredName = nil
            }
            break
        case NSStreamEvent.HasBytesAvailable:
            print("HasBytesAvailable")
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
            
        case NSStreamEvent.HasSpaceAvailable:
            print("HasSpaceAvailable")
            if self.openedStreams == 2 && !self.streamsConnected {
                NSLog("streams connected.")
                self.streamsConnected = true
                self.streamsConnectedCallback?()
            }
            break
            
        case NSStreamEvent.ErrorOccurred:
            print("ErrorOccurred")
            break
            
        case NSStreamEvent.EndEncountered:
            print("EndEncountered")
            break
            
        default:
            break
        }
    }
}


extension ZHBonjour: NSNetServiceBrowserDelegate {
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
//        self.services = self.services.filter() { $0 != service }
//        
//        if !moreComing {
//            if let callback = self.servicesCallback {
//                callback(self.services)
//            }
//        }
    }
}