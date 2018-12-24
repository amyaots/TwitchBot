//
//  Bot+Snowball.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 09/12/2018.
//

import Foundation

struct SnowOption {
    let text: String
    let time: Int
    let isSelf: Bool
    
    init(_ text: String, time: Int = 0, isSelf: Bool = false) {
        self.text = text
        self.time = time
        self.isSelf = isSelf
    }
}

extension Bot {
    
    private static var snowTime = [String: Date]()
    private static let snowballTimeout = 60
    
    static let snowOptions = [
        SnowOption("Oh man, @user1 just blew user2 right into the mess.", time: 180),
        SnowOption("@user1 throws a snowball and .... Oh, user2 It must be painful!", time: 120),
        SnowOption("user2 yelled 'YO, @user1 No snowballs! You'll hit someone in the eye."),
        SnowOption("@user1 wounded user2, a simple wound in the body.", time: 30),
        SnowOption("Refraining from his throwing technique, @user1 goes straight to user2 and throws a snowball at his face.", time: 60),
        SnowOption("Creeping up, @user1 gets behind user2 and throws snow right at the backside.", time: 30),
        SnowOption("@user1, also known by the nickname 'Shooter', breaks user2 with a terrible shot.", time: 120),
        SnowOption("Getting a humiliating shot in the ass from @user1, user2 falls in pain.", time: 60),
        SnowOption("@user1 gets a snowball in the ear user2 - this is a hit! PogChamp", time: 60),
        SnowOption("@user1 is the same master of throwing a snowball as user2, so he got himself a snowball", time: 60, isSelf: true),
        SnowOption("@user1 got into user2", time: 30),
        SnowOption("@user1 shoots user2, and slips through as the snowball was badly made."),
        SnowOption("@user1, lazily throwing, misses as much as a mile into user2"),
        SnowOption("user2 runs like the wind and avoids the dreaded yellow snowball from @user1"),
        SnowOption("Everyone freaks out as @user1 throws a powder ball at user2, which never reaches the goal."),
        SnowOption("user2 survived, since @user1 is not strong in the art of making snowballs, which he demonstrated to everyone."),
        SnowOption("Blinded by the sun, @user1 throws a snowball far to the side. user2 can only giggle."),
        SnowOption("user2 hides behind the machine, and dodges the snowball launched by @user1"),
        SnowOption("@user1 threw a snowball at user2, but he safely dodged buried in the ground like a turtle."),
        SnowOption("@user1 mixed snow with magic pollen and stubbed.")
    ]
    
    func handleSnowball(throwUser: String, otherUser: String) {
        guard checkTime(for: throwUser) else {
            return
        }
        Bot.snowTime[throwUser] = Date()
        
        var otherNick = otherUser.lowercased()
        otherNick.removeFirst()
        guard throwUser.lowercased() != otherNick else {
            send("@\(throwUser), use command !roulette")
            return
        }
        
        if otherNick == currentChannel {
            send("\(otherUser) hiding behind a magical barrier that reflects the snowball back to @\(throwUser).")
            muteUser(nick: throwUser, time: 30)
            return
        }
        
        let isOtherUserModer = chatters?.chatters.moderators.contains(otherNick) ?? false
        if isOtherUserModer {
            send("\(otherUser) cuts the snowball thrown into it with his sword.")
            return
        }
        
        var isOtherUserOnline = false
        if let chatters = chatters {
            isOtherUserOnline = chatters.chatters.viewers.contains(otherNick) || chatters.chatters.vips.contains(otherNick)
        }
        
        guard isOtherUserOnline else {
            send("@\(throwUser) try to someone else")
            return
        }
        
        guard let option = Bot.snowOptions.random else { return }
        let message = replace(message: option.text, throwUser, otherUser)
        send(message)
        if option.time > 0 {
            let muteNick = option.isSelf ? throwUser : otherUser
            muteUser(nick: muteNick, time: option.time)
        }
    }
    
    private func checkTime(for user: String) -> Bool {
        guard let lastTime = Bot.snowTime[user] else {
            return true
        }
        guard let sec = Calendar.current.dateComponents([.second], from: lastTime, to: Date()).second else {
            return true
        }
        if sec < Bot.snowballTimeout {
            let timeout = Bot.snowballTimeout - sec
            send("@\(user), chill! To next snowball \(timeout) sec.")
        }
        return sec >= Bot.snowballTimeout
    }
    
    private func replace(message: String, _ throwUser: String, _ otherUser: String) -> String {
        var result = message.replacingOccurrences(of: "user1", with: throwUser)
        result = result.replacingOccurrences(of: "user2", with: otherUser)
        return result
    }
}
