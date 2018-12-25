//
//  Bot+8Ball.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 23/12/2018.
//

extension Bot {
    
    static let answers = [
        "reply hazy try again.",
        "ask again later.",
        "better not tell you now.",
        "cannot predict now.",
        "go for it!",
        "yes, in due time.",
        "yeah, for sure.",
        "probably.",
        "never going to happen!",
        "my reply is no.",
        "very doubtful.",
        "no.",
        "who knows?",
        "signs point to yes.",
        "it is certain.",
        "outlook good.",
        "yes",
        "no",
        "as I see it, yes.",
        "there's a pretty good chance.",
        "тo, don't even think about.",
        "signs point to yes."
    ]
    
    func handleBall(string command: String, nick: String) {
        let regexText = " \\w+"
        let matchStrings = command.matches(for: regexText)
        guard let text = Bot.answersRus.randomElement(), matchStrings.count > 0 else {
            return
        }
        send(for: nick, ", " + text)
    }
}
