//
//  BotTimers.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 23/12/2018.
//

import Dispatch

final class BotTimers {
    
    private let queue: DispatchQueue
    private var timers = [String: DispatchSourceTimer]()
    
    init() {
        queue = DispatchQueue(label: "com.nexbot.app.timers")
    }
    
    func addTimer(with name: String, repeating: Double, closure: @escaping () -> Void) {
        let newTimer = DispatchSource.makeTimerSource(queue: queue)
        newTimer.schedule(deadline: .now(), repeating: repeating)
        newTimer.setEventHandler {
            closure()
        }
        timers[name] = newTimer
        newTimer.resume()
    }
    
    func stopTimer(with name: String) {
        timers[name]?.cancel()
        timers[name] = nil
    }
    
    deinit {
        timers.forEach {
            $0.value.cancel()
        }
        timers.removeAll()
    }
}
