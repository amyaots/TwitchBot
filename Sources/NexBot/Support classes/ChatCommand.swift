//
//  ChatCommand.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 22/12/2018.
//

enum ChatCommand: String {
    case join = "JOIN"
    case message = "PRIVMSG"
    case part = "PART"
    case ping = "PING"
    case pong = "PONG"
    case notice = "NOTICE"
    case roomState = "ROOMSTATE"
    case userState = "USERSTATE"
    case reconnect = "RECONNECT"
    case auth = "PASS"
    case nick = "NICK"
    case unknown
}

extension ChatCommand: CustomStringConvertible {
    var description: String {
        return self.rawValue
    }
}
