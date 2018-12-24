//
//  TwitchCommand.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 23/12/2018.
//

enum TwitchCommand: String {
    case me = "/me"
    case timeout = "/timeout"
    case unknown
}

extension TwitchCommand: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
