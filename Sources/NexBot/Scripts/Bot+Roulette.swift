//
//  Bot+Roulette.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 08/12/2018.
//

import Foundation

extension Bot {
    
    static let rouletteAnswers = [
        " has lived to survive roulette!",
        " is lucky, and lives another day!",
        " has been saved by magic!",
        " has lived due to not having anything in their skull to begin with.",
        "  did not die from the bullet, the bullet died from them.",
        "die"
    ]
    
    private static var rouletteTime = [String: Date]()
    private static let rouletteTimeout = 60

    func handleRoulette(_ nick: String) {
        
        guard checkTime(for: nick) else {
            return
        }
        Bot.rouletteTime[nick] = Date()
        
        guard let answer = Bot.rouletteAnswers.randomElement() else { return }
        guard answer != "die" else {
            handleDie(nick)
            return
        }
        send(for: nick, answer)
    }
    
    func handleDie(_ nick: String) {
        var users = [String]()
        if let chatters = chatters {
            users.append(contentsOf: chatters.chatters.vips)
            users.append(contentsOf: chatters.chatters.viewers)
        }
        let randomUser = users.random ?? ""
        let maxCount = randomUser.isEmpty ? 2 : 3
        let random = Int.random(in: 0...maxCount)
        switch random {
        case 0:
            send(for: nick, "  lies dead in the chat.")
            muteUser(nick: nick, time: 60)
        case 1:
            send(for: nick, " loses their head!")
            muteUser(nick: nick, time: 180)
        case 2:
            send(for: nick, " crashes to the floor like a sack of flour!")
            muteUser(nick: nick, time: 120)
        case 3:
            send(for: nick, " just killed @\(randomUser).")
            muteUser(nick: randomUser, time: 60)
        default:
            break
        }
    }
    
    private func checkTime(for user: String) -> Bool {
        guard let lastTime = Bot.rouletteTime[user] else {
            return true
        }
        guard let sec = Calendar.current.dateComponents([.second], from: lastTime, to: Date()).second else {
            return true
        }
        if sec < Bot.rouletteTimeout {
            let timeout = Bot.rouletteTimeout - sec
            send("@\(user), to next shoot \(timeout) sec.")
        }
        return sec >= Bot.rouletteTimeout
    }
}
