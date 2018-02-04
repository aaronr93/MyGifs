//
//  Feed.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

public protocol Gif {
    var smallUrl: URL { get }
    var fullResUrl: URL { get }
    var thumbnailImageUrl: URL? { get }
    var title: String? { get }
    func size() -> CGSize
}
public protocol GfyFeed {
    var gfys: [Gif] { get set }
    var numberOfItemsInFeed: Int { get }
    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ())
}

