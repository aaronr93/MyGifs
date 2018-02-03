//
//  GfycatTagFeedModel.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/30/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

final public class GfyTagsFeed {
    var cursor: String?
    var tags: [GfyTagModel]?
    
    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ()) {
        
    }
}

struct GfyTagModel: Decodable {
    var tag: GfyTag
    var gfycats: [GfyModel]
    var cursor: String?
    var digest: String?
    var tagText: String?
}

typealias GfyTag = String
