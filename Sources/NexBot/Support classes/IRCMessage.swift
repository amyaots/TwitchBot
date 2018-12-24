//
//  IRCMessage.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 22/12/2018.
//

struct IRCMessage {
    
    let text: String?
    let command: ChatCommand
    let params: [String: Any]
    let targets: [String]
    let senderNick: String?
    
    var nick: String {
        return (params["display-name"] as? String) ?? senderNick ?? ""
    }
}
