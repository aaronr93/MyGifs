//
//  Feed.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation
import AVFoundation

protocol Gif {
    var thumbnailUrl: URL { get }
    var thumbnailAsset: AVAsset { get }
}
protocol GfyFeed {
    var gfys: [Gfy] { get set }
    var numberOfItemsInFeed: Int { get }
    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ())
}

enum FeedModelType {
    case feedModelTypeGfyUser
    case feedModelTypeGfyTag
}
