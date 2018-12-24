//
//  ParseIRC.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 22/12/2018.
//

import Foundation

enum ParseIRC {
    
    private enum Symbols: String, CustomStringConvertible {
        
        var description: String {
            return self.rawValue
        }
        
        case space = " "
        case slash = "/"
        case colon = ":"
        case exclamationMark = "!"
        case atSymbol = "@"
        case carriageReturn = "\r\n"
        case empty = ""
        case separate = ";"
    }
    
    static func handle(_ string: String) -> IRCMessage? {
        
        var trimmedString = string.replacingOccurrences(of: Symbols.carriageReturn.rawValue, with: Symbols.empty.rawValue)
        
//        let message = trimmedString // full IRC text
        var tags = [String: Any]()
        var nickname: String?
        var parameters: String?
        var command = ""
        var target = [String]()
        
        guard let firstSpaceIndex = trimmedString.range(of: Symbols.space.rawValue)?.lowerBound else {
            // The message is invalid if there isn't a single space
            return nil
        }
        
        var possibleTags = trimmedString[trimmedString.startIndex ..< firstSpaceIndex]
        
        if !possibleTags.isEmpty && possibleTags.hasPrefix(Symbols.atSymbol.rawValue) {
            // There are tags present
            // Remove the @ symbol
            possibleTags.remove(at: possibleTags.startIndex)
            
            // Seperate by ;
            for tag in possibleTags.components(separatedBy: Symbols.separate.rawValue) {
                /*
                 <tag>           ::= <key> ['=' <escaped value>]
                 <key>           ::= [ <vendor> '/' ] <sequence of letters, digits, hyphens (`-`)>
                 */
                guard let equalSignIndex = tag.range(of: "=")?.lowerBound else {
                    print("Invalid tag: \(tag)")
                    continue
                }
                
                let key = tag[tag.startIndex ..< equalSignIndex]
                
                var value: String? = String(tag[tag.index(after: equalSignIndex) ..< tag.endIndex])
                
                if value!.isEmpty {
                    value = nil
                }
                
                guard !key.isEmpty else {
                    print("Unexpected empty key: \(tag)")
                    continue
                }
                
                tags[String(key)] = value
            }
            
            // Remove the tags so the old code works
            trimmedString.removeSubrange(trimmedString.startIndex ... firstSpaceIndex)
        }
        
        if trimmedString[trimmedString.startIndex] == Character(Symbols.colon.rawValue) {
            // There is a prefix, and we must handle and trim it
            let indexAfterColon = trimmedString.index(after: trimmedString.startIndex)
            let indexOfSpace = trimmedString.range(of: Symbols.space.rawValue)!.lowerBound
            let prefixString = trimmedString[indexAfterColon ..< indexOfSpace]
            nickname = parseNick(String(prefixString))
            // Trim off the prefix
            trimmedString = String(trimmedString[trimmedString.index(after: indexOfSpace) ..< trimmedString.endIndex])
        }
        
        if let colonSpaceRange = trimmedString.range(of: " :") {
            // There are parameters
            let commandAndTargetString = trimmedString[trimmedString.startIndex ..< colonSpaceRange.lowerBound]
            // Space seperated array
            var commandAndTargetComponents = commandAndTargetString.components(separatedBy: " ")
            command = commandAndTargetComponents.remove(at: 0)
            target = commandAndTargetComponents
            
            // If the command is a 3-didgit numeric, the first target must go
            if let cmd = Int(command) {
                if cmd >= 0 && cmd < 1000  && target.count > 0 {
                    target.remove(at: 0)
                }
            }
            
            // If this check if not performed, this code could crash if the last character of trimmedString is a colon
            if colonSpaceRange.upperBound != trimmedString.endIndex {
                var parametersStart = trimmedString.index(after: colonSpaceRange.upperBound)
                // Fixes a bug where the first character of the parameters is cut off
                parametersStart = trimmedString.index(before: parametersStart)
                parameters = String(trimmedString[parametersStart ..< trimmedString.endIndex])
            }
        } else {
            // There are no parameters
            var spaceSeperatedArray = trimmedString.components(separatedBy: " ")
            command = spaceSeperatedArray.remove(at: 0)
            target = spaceSeperatedArray
        }
        
        let chatCommand = ChatCommand(rawValue: command) ?? .unknown
        return IRCMessage(text: parameters, command: chatCommand, params: tags, targets: target, senderNick: nickname)
    }
    
    private static func parseNick(_ string: String) -> String? {
        
        guard string.contains(Symbols.exclamationMark.rawValue) && string.contains(Symbols.atSymbol.rawValue),
            let exclamationMark = string.range(of: Symbols.exclamationMark.rawValue) else {
            return nil
        }
        return String(string[string.startIndex ..< exclamationMark.lowerBound])
    }
}
