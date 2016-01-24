//
//  ZHConnectivity.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 1/23/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//


// Example use from a watchkit project
//        class myclass {
//
//            var session: WCSession? = nil
//
//            private func startSession() {
//                if(WCSession.isSupported()) {
//                    session = WCSession.defaultSession()
//                    session?.delegate = self
//                    session?.activateSession()
//                }
//            }
//
//            private func sendUserToWatch() {
//                if let session = session where session.reachable {
//                    if let userDicationary = user?.dictionaryRepresentation() {
//                        session.sendMessage(["user": userDicationary], replyHandler: { (replies: [String : AnyObject]) -> Void in
//                            if let reply = replies["reply"] as? String {
//                                print("Received reply: " + reply)
//                            } else {
//                                print("Failed to parse message")
//                            }
//                            }, errorHandler: { (error: NSError) -> Void in
//                                print("error: " + error.localizedDescription)
//                        })
//                    }
//                }
//            }
//        }
//
//            extension ZHHomeViewController: WCSessionDelegate {
//                func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
//                    if let user = message["user"] as? String {
//                        print("received message: " + user)
//                        let reply = ["reply": "a reply message"]
//                        replyHandler(reply)
//                    } else {
//                        print("Failed to parse message")
//                    }
//                    
//                }
//            }

import Foundation

/** -------------------------------- WCSession ----------------------------------
 *  The default session is used to communicate between two counterpart apps
 *  (i.e. iOS app and its native WatchKit extension). The session provides
 *  methods for sending, receiving, and tracking state.
 *
 *  On start up an app should set a delegate on the default session and call
 *  activate. This will allow the system to populate the state properties and
 *  deliver any outstanding background transfers.
 */
@available(iOS 9.0, *)

public class ZHSession : NSObject {
    
    private static let sharedInstance = ZHSession()
    
    /** Check if session is supported on this iOS device. Session is always available on WatchOS */
    public class func isSupported() -> Bool {
        return true
    }
    
    /** Use the default session for all transferring of content and state monitoring. */
    public class func defaultSession() -> ZHSession {
        return ZHSession.sharedInstance
    }

    /** Use the default session instead. */

     /** A delegate must exist before the session will allow sends. */
    weak public var delegate: ZHSessionDelegate?

    /** The default session must be activated on startup before the session will begin receiving delegate callbacks. Calling activate without a delegate set is undefined. */
    public func activateSession() {
        BonjourTCPServer.sharedInstance.dataReceivedCallback = {(data: String) in
            self.delegate?.session?(self, didReceiveMessage: ["data": data])
        }
        
        
    }

    public func listClients() -> [ZHSessionClient]? {
        return nil
    }
    
    
    
    
    /** ------------------------- iOS App State For Watch ---------------------------
     *  State information that applies to Watch and is only available to the iOS app.
     *  This information includes device state, counterpart app state, and iOS app
     *  information specific to Watch.
     */
     
     /** Check if iOS device is paired to a watch */
    public var paired: Bool {
        // TODO: Implement
        return true
    }

    /** Check if the user has the Watch app installed */
    public var watchAppInstalled: Bool {
        // TODO: Implement
        return true
    }

    /** Check if the user has the Watch app's complication enabled */
    public var complicationEnabled: Bool {
        return false
    }

    /** Use this directory to persist any data specific to the Watch. This directory will be deleted upon next launch if the watch app is uninstalled. If the watch app is not installed value will be nil. */
    public var watchDirectoryURL: NSURL? {
        // TODO: Implement
        return nil
    }
    
    /** -------------------------- Interactive Messaging ---------------------------
     *  Interactive messages can only be sent between two actively running apps.
     *  They require the counterpart app to be reachable.
     */
     
     /** The counterpart app must be reachable for a send message to succeed. */
    public var reachable: Bool {
        // TODO: Implement
        return true
    }

    /** Reachability in the Watch app requires the paired iOS device to have been unlocked at least once after reboot. This property can be used to determine if the iOS device needs to be unlocked. If the reachable property is set to NO it may be because the iOS device has rebooted and needs to be unlocked. If this is the case, the Watch can show a prompt to the user suggesting they unlock their paired iOS device. */
     
     /** Clients can use this method to send messages to the counterpart app. Clients wishing to receive a reply to a particular message should pass in a replyHandler block. If the message cannot be sent or if the reply could not be received, the errorHandler block will be invoked with an error. If both a replyHandler and an errorHandler are specified, then exactly one of them will be invoked. Messages can only be sent while the sending app is running. If the sending app exits before the message is dispatched the send will fail. If the counterpart app is not running the counterpart app will be launched upon receiving the message (iOS counterpart app only). The message dictionary can only accept the property list types. */
    public func sendMessage(message: [String : AnyObject], client: ZHSessionClient, replyHandler: (([String : AnyObject]) -> Void)?, errorHandler: ((NSError) -> Void)?) {
        // TODO: Implement
    }

//    /** Clients can use this method to send message data. All the policies of send message apply to send message data. Send message data is meant for clients that have an existing transfer format and do not need the convenience of the send message dictionary. */
//    public func sendMessageData(data: NSData, client: ZHSessionClient, replyHandler: ((NSData) -> Void)?, errorHandler: ((NSError) -> Void)?) {
//        // TODO: Implement
//    }
//    
//    /** --------------------------- Background Transfers ---------------------------
//     *  Background transfers continue transferring when the sending app exits. The
//     *  counterpart app (other side) is not required to be running for background
//     *  transfers to continue. The system will transfer content at opportune times.
//     */
//     
//     /** Setting the applicationContext is a way to transfer the latest state of an app. After updating the applicationContext, the system initiates the data transfer at an appropriate time, which can occur after the app exits. The counterpart app will receive a delegate callback on next launch if the applicationContext has successfully arrived. If there is no app context, it should be updated with an empty dictionary. The applicationContext dictionary can only accept the property list types. */
//    public var applicationContext: [String : AnyObject] {
//        
//        get {
//            // TODO: Implement
//        }
//        set {
//            // TODO: Implement
//        }
//    }
//    
//    public func updateApplicationContext(applicationContext: [String : AnyObject]) throws {
//        // TODO: Implement
//    }
//    
//    /** Stores the most recently received applicationContext from the counterpart app. */
//    public var receivedApplicationContext: [String : AnyObject] {
//        // TODO: Implement
//        get {
//            // TODO: Implement
//        }
//        set {
//            // TODO: Implement
//        }
//    }
//
//    /** The system will enqueue the user info dictionary and transfer it to the counterpart app at an opportune time. The transfer of user info will continue after the sending app has exited. The counterpart app will receive a delegate callback on next launch if the file has successfully arrived. The userInfo dictionary can only accept the property list types.
//     */
//    public func transferUserInfo(userInfo: [String : AnyObject]) -> ZHSessionUserInfoTransfer {
//        // TODO: Implement
//    }
//
//    
//    /** Enqueues a user info dictionary containing the most current information for an enabled complication. If the app's complication is enabled the system will try to transfer this user info immediately. Once a current complication user info is received the system will launch the Watch App Extension in the background and allow it to update the complication content. If the current user info cannot be transferred (i.e. devices disconnected, out of background launch budget, etc.) it will wait in the outstandingUserInfoTransfers queue until next opportune time. There can only be one current complication user info in the outstandingUserInfoTransfers queue. If a current complication user info is outstanding (waiting to transfer) and -transferCurrentComplicationUserInfo: is called again with new user info, the new user info will be tagged as current and the previously current user info will be untagged. The previous user info will however stay in the queue of outstanding transfers. */
//    public func transferCurrentComplicationUserInfo(userInfo: [String : AnyObject]) -> ZHSessionUserInfoTransfer {
//        // TODO: Implement
//    }
//
//    
//    /** Returns an array of user info transfers that are still transferring (i.e. have not been cancelled, failed, or been received by the counterpart app).*/
//    public var outstandingUserInfoTransfers: [ZHSessionUserInfoTransfer] {
//        // TODO: Implement
//        get {
//            // TODO: Implement
//        }
//        set {
//            // TODO: Implement
//        }
//
//    }
//
//    
//    /** The system will enqueue the file and transfer it to the counterpart app at an opportune time. The transfer of a file will continue after the sending app has exited. The counterpart app will receive a delegate callback on next launch if the file has successfully arrived. The metadata dictionary can only accept the property list types. */
//    public func transferFile(file: NSURL, metadata: [String : AnyObject]?) -> ZHSessionFileTransfer {
//        // TODO: Implement
//    }
//
//    
//    /** Returns an array of file transfers that are still transferring (i.e. have not been cancelled, failed, or been received by the counterpart app). */
//    public var outstandingFileTransfers: [ZHSessionFileTransfer] {
//        // TODO: Implement
//        get {
//            // TODO: Implement
//        }
//        set {
//            // TODO: Implement
//        }
//    }
}

/** ----------------------------- WCSessionDelegate -----------------------------
 *  The session calls the delegate methods when content is received and session
 *  state changes. All delegate methods will be called on the same queue. The
 *  delegate queue is a non-main serial queue. It is the client's responsibility
 *  to dispatch to another queue if neccessary.
 */
@objc public protocol ZHSessionDelegate : NSObjectProtocol {
    
    /** ------------------------- iOS App State For Watch ------------------------ */
     
     /** Called when any of the Watch state properties change */
    @available(iOS 9.0, *)
    optional func sessionWatchStateDidChange(session: ZHSession)
    
    /** ------------------------- Interactive Messaging ------------------------- */
     
     /** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
    @available(iOS 9.0, *)
    optional func sessionReachabilityDidChange(session: ZHSession)
    
    /** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveMessage message: [String : AnyObject])
    
    /** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void)
    
    /** Called on the delegate of the receiver. Will be called on startup if the incoming message data caused the receiver to launch. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveMessageData messageData: NSData)
    
    /** Called on the delegate of the receiver when the sender sends message data that expects a reply. Will be called on startup if the incoming message data caused the receiver to launch. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveMessageData messageData: NSData, replyHandler: (NSData) -> Void)
    
    /** -------------------------- Background Transfers ------------------------- */
     
     /** Called on the delegate of the receiver. Will be called on startup if an applicationContext is available. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveApplicationContext applicationContext: [String : AnyObject])
    
    /** Called on the sending side after the user info transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the user info finished. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didFinishUserInfoTransfer userInfoTransfer: ZHSessionUserInfoTransfer, error: NSError?)
    
    /** Called on the delegate of the receiver. Will be called on startup if the user info finished transferring when the receiver was not running. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveUserInfo userInfo: [String : AnyObject])
    
    /** Called on the sending side after the file transfer has successfully completed or failed with an error. Will be called on next launch if the sender was not running when the transfer finished. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didFinishFileTransfer fileTransfer: ZHSessionFileTransfer, error: NSError?)
    
    /** Called on the delegate of the receiver. Will be called on startup if the file finished transferring when the receiver was not running. The incoming file will be located in the Documents/Inbox/ folder when being delivered. The receiver must take ownership of the file by moving it to another location. The system will remove any content that has not been moved when this delegate method returns. */
    @available(iOS 9.0, *)
    optional func session(session: ZHSession, didReceiveFile file: ZHSessionFile)
}