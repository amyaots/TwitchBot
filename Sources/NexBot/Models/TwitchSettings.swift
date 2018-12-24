//
//  TwitchSettings.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 22/12/2018.
//

struct TwitchSettings {
    let token: String
    let nick: String
    let channel: String
    let capabilities = "CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership"
}
