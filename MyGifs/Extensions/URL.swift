//
//  URL.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

extension URL {
    
    static func URLForUser(username: String) -> URL {
        let urlString = Const.Gfy.baseURLString + Const.Gfy.userFeed + "/" + username + Const.Gfy.gfycatsFeed
        return URL(string: urlString)!
    }
    
}
