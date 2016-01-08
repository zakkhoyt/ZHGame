//
//  ZHBonjourTCPConfig.swift
//  ZHGameIOS
//
//  Created by Zakk Hoyt on 1/7/16.
//  Copyright © 2016 Zakk Hoyt. All rights reserved.
//

import Foundation

let ZHBonjourTCPServiceName = "_vaporwarewolf_service._tcp."



enum ZHBonjourTCPCommandType: NSString {
    case JoinGame = "join_game"
    case LeaveGame = "leave_game"
    case StartGame = "start_game"
    case RoundQuestion = "round_question"
    case RoundAnswer = "round_answer"
    case RoundOver = "round_over"
    case GameOver = "game_over"
    

}

class ZHBonjourTCPCommand: NSObject {
    class func command(type: ZHBonjourTCPCommandType, payload: NSDictionary) -> NSDictionary {
        return ["command": type.rawValue, "payload": payload]
    }
}
