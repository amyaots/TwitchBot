//
//  Bot.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 22/12/2018.
//

import WebSocket

final class Bot {
    
    // MARK: - Consts
    
    private enum Consts {
        enum URLs {
            static let chat = "irc-ws.chat.twitch.tv"
            static let api = "tmi.twitch.tv"
        }
        enum Regex {
            static let command = "^!\\w+"
            static let otherUser = "@\\w+"
        }
        enum Timers: String {
            case advertisingEsti
            case updateChatters
        }
    }
    
    // MARK: - Commands
    
    enum Command: String {
        case unknown
        case ball = "!ball"
        case roulette = "!roulette"
        case snowball = "!snowball"
        case creator = "!creator"
        case test = "!test"
    }
    
    // MARK: - Properties
    
    private let settings: TwitchSettings
    private let worker = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    private var ws: WebSocket?
    private let timers = BotTimers()
    
    var isConnected = false
    var chatters: OnlineUsers?
    
    var currentChannel: String {
        return settings.channel
    }
    
    // MARK: - Init
    
    init(oauth: String, nick: String, channel: String) {
        settings = TwitchSettings(token: oauth, nick: nick, channel: channel)
        HTTPClient.webSocket(scheme: .wss, hostname: Consts.URLs.chat,on: worker).whenSuccess { [weak self] ws in
            self?.ws = ws
            print("Success create connection")
            self?.connect()
        }
    }
    
    func connect() {
        ws?.onText { [weak self] _, text in
            self?.handle(text)
        }
        joinChannel()
        isConnected = true
        startUpdateChatters()
    }
    
    func reconnect() {
        ws?.send("\(ChatCommand.reconnect)")
    }
    
    /// disconnect from twith and close connection
    func disconnect() {
        timers.stopTimer(with: Consts.Timers.advertisingEsti.rawValue)
        timers.stopTimer(with: Consts.Timers.updateChatters.rawValue)
        guard let ws = ws else { return }
        ws.send("\(ChatCommand.part) #\(settings.channel)")
        ws.close()
        ws.onClose.whenComplete { [weak self] in
            self?.isConnected = false
            print("Bot disconnected")
            self?.ws = nil
        }
    }
    
    /// send message to channel
    ///
    /// - Parameter message: text message
    func send(_ message: String) {
        ws?.send("\(ChatCommand.message) #\(settings.channel) :\(message)")
    }
    
    func muteUser(nick: String, time: Int) {
        send("\(TwitchCommand.timeout) \(nick) \(time)")
    }
    
    func send(for nick: String, _ text: String) {
        send("@\(nick)\(text)")
    }
    
    deinit {
        disconnect()
    }
}

// MARK: - Private methods

private extension Bot {
    
    func joinChannel() {
        guard let ws = ws else { return }
        ws.send("\(ChatCommand.auth) \(settings.token)")
        ws.send("\(ChatCommand.nick) \(settings.nick)")
        ws.send(settings.capabilities)
        ws.send("\(ChatCommand.join) #\(settings.channel)")
    }
    
    func handle(_ text: String) {
        guard let ircMessage = ParseIRC.handle(text) else { return }
        switch ircMessage.command {
        case .ping:
            pong()
        case .message:
            handleMessage(ircMessage)
        case .join:
            print("\(ircMessage.nick) connected to channel")
        case .part:
            print("\(ircMessage.nick) leave channel")
        default:
            break
        }
    }
    
    func handleMessage(_ prvMessage: IRCMessage) {
        guard let textCommand = prvMessage.text else { return }
        guard let matchCommand = textCommand.matches(for: Consts.Regex.command).first,
            let command = Command(rawValue: matchCommand) else {
                return
        }
        switch command {
        case .test:
            send("\(TwitchCommand.me) hello world")
        case .creator:
            send("My creator @Nexelen")
        case .snowball:
            let matchStrings = textCommand.matches(for: Consts.Regex.otherUser)
            guard let otherUser = matchStrings.first else { return }
            handleSnowball(throwUser: prvMessage.nick, otherUser: otherUser)
        case .roulette:
            handleRoulette(prvMessage.nick)
        case .ball:
            guard let text = prvMessage.text else { return }
            handleBall(string: text, nick: prvMessage.nick)
        default:
            break
        }
    }
    
    func pong() {
        ws?.send("\(ChatCommand.pong) :\(Consts.URLs.api)")
    }
    
    func startUpdateChatters() {
        timers.addTimer(with: Consts.Timers.updateChatters.rawValue, repeating: 60) { [weak self] in
            self?.obtainChatters()
        }
    }
    
    func obtainChatters() {
        let requestChatters = HTTPRequest(method: .GET, url: "/group/user/\(settings.channel)/chatters")
        HTTPClient.connect(scheme: .https, hostname: Consts.URLs.api, on: worker).then { client in
            client.send(requestChatters)
        }.whenSuccess { [weak self] response in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let data = response.body.data {
                self?.chatters = try? decoder.decode(OnlineUsers.self, from: data)
            }
        }
    }
}
