//
//  main.swift
//  NexBot
//
//  Created by Aleksandr Myaots on 01/12/2018.
//  Copyright © 2018 Aleksandr Myaots. All rights reserved.
//

import WebSocket

let app = Application()
app.run()
//let worker = MultiThreadedEventLoopGroup(numberOfThreads: 2)
//
//let client = try HTTPClient.connect(scheme: .https, hostname: "tmi.twitch.tv", on: worker).wait()
//print(client) // HTTPClient
//// Create an HTTP request: GET /
//let httpReq = HTTPRequest(method: .GET, url: "")
//// Send the HTTP request, fetching a response
//let httpRes = try client.send(httpReq).wait()
//
//let decoder = JSONDecoder()
//decoder.keyDecodingStrategy = .convertFromSnakeCase
//if let data = httpRes.body.data {
//    let online = try? decoder.decode(OnlineUsers.self, from: data)
////    try client.onClose.wait()
//    print(online)
//}

