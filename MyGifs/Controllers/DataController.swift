//
//  DataController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

fileprivate let kMaxPaginatedGfys = 10

class DataController {
    var cursor: String = ""
    var lastPage: Bool = false
    
    /// Temporary measure until username picker is implemented
    var user: String = "sannahparker"   // Some random user found on the front page
    
    func parseGifs(from data: Data) -> [Gfy]? {
        guard let userFeed = try? JSONDecoder().decode(UserFeed.self, from: data) else {
            print("Error decoding JSON to UserFeed")
            return nil
        }
        if let cursorValue = userFeed.cursor {
            cursor = cursorValue
        }
        if let count = userFeed.gfycats?.count {
            if count < kMaxPaginatedGfys {
                lastPage = true
            }
        }
        return userFeed.gfycats
    }
    
    func createPlayer(from gfy: Gfy) -> GifPlayer? {
        if let miniUrl = gfy.miniUrl {
            return GifPlayer(url: miniUrl)
        }
        return nil
    }
    
    /// If the `cursor` property of `DataController` is set, returns
    /// its value in a URL parameter; otherwise returns nil.
    func getCursorParam() -> Dictionary<String, Any>? {
        if (cursor != "") {
            return ["cursor": cursor]
        }
        return nil
    }
    
}

