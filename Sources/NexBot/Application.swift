//
//  Application.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 22/12/2018.
//

import Foundation

final class Application {
    
    // MARK: - Commands
    
    private enum Command: String {
        case q
        case c
        case d
        case r
        case s
        case h
        case unknown
    }
    
    // MARK: - Properties
    
    private var isRunning = true
    private var bot: Bot?
    
    // MARK: - Init
    
    init() {
        print("Hello! Its NexBot programm!")
        print("What do you want?")
        printCommands()
    }
    
    // MARK: - Run loop
    
    func run() {
        
        while isRunning {
            
            let commandString = readLine() ?? ""
            let command = Command(rawValue: commandString) ?? .unknown
            
            switch command {
            case .q:
                isRunning = false
            case .unknown:
                print("Unknown command please send:")
                printCommands()
            case .c:
                createBot()
                bot?.connect()
            case .h:
                printCommands()
            case .d:
                bot?.disconnect()
            case .s:
                sendMessage()
            default:
                break
            }
        }
    }
    
}

// MARK: - Private methods

private extension Application {
    
    /// create bot instance
    func createBot() {
        print("Enter oauth key:")
        let key = readLine() ?? ""
        print("Enter nickname bot:")
        let nick = readLine() ?? ""
        print("Enter channel name to connect:")
        let channel = readLine() ?? ""
        bot = Bot(oauth: key, nick: nick, channel: channel.lowercased())
    }
    
    /// print available commands
    func printCommands() {
        print("c -\t connect bot")
        print("d -\t disconnect bot")
        print("r -\t reconnect bot")
        print("s -\t send message from bot")
        print("h -\t help")
        print("q -\t exit")
    }
    
    func sendMessage() {
        print("Enter message to send from bot:")
        let text = readLine() ?? ""
        bot?.send(text)
    }
}
