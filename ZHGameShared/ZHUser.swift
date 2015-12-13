//
//  ZHUser.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 12/12/15.
//  Copyright © 2015 Zakk Hoyt. All rights reserved.
//

import Foundation


class ZHUser {
    var username: String? = nil
    var uuid: String? = nil
    
    func jsonRepresentation() -> String? {
        let dictionary = ["username": username!, "uuid": uuid!]
        do {
            
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary, options: .PrettyPrinted)
            let jsonString = NSString(data: jsonData, encoding: NSASCIIStringEncoding)
            print("JSON string = \(jsonString)")

        } catch _ {
            print("Error converting dictionary to json string")
            return nil
        }
        return nil
    }
}