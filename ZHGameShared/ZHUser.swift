//
//  ZHUser.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 12/12/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import Foundation


class ZHUser: NSObject {
    var username: String? = nil
    var uuid: String? = nil
    
    func jsonRepresentation() -> String? {
        let dictionary = ["username": username!, "uuid": uuid!]
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: NSASCIIStringEncoding)
            if let jsonString = jsonString {
                print("JSON string = \(jsonString)")
                return jsonString as String!
            } else {
                print("JSON string is nil")
            }
        } catch _ {
            print("Error converting dictionary to json string")
            return nil
        }
        return nil
    }
    
    init(jsonString: String) {
        super.init()
        

        let jsonData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
        do {
            let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as? Dictionary<String, AnyObject>
            if let jsonDictionary = jsonDictionary {
                if let username = jsonDictionary["username"] {
                    self.username = username as? String
                }
                
                if let uuid = jsonDictionary["uuid"] {
                    self.uuid = uuid as? String
                }
            }
        } catch _ {
            print("Error converting string to data to json dictionary")
        }
    }
    override init(){
        super.init()
    }
}