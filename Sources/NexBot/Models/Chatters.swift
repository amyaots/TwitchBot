//
//  Chatters.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 18/12/2018.
//

import Foundation

struct OnlineUsers: Decodable {
    let chatterCount: Int
    let chatters: Chatters
}

struct Chatters: Decodable {
    let vips: [String]
    let moderators: [String]
    let staff: [String]
    let admins: [String]
    let globalMods: [String]
    let viewers: [String]
}
