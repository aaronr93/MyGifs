//
//  Feed.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

public protocol SendableItem {
    var viewableUrl: URL { get }
    var title: String? { get }
}

protocol Gif: SendableItem {
    var smallUrl: URL { get }
    var fullResUrl: URL { get }
    var thumbnailImageUrl: URL? { get }
    func size() -> CGSize
}

protocol Feed {
    var url: URL? { get }
    var numberOfItemsInFeed: Int { get }
    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ())
}

protocol GifFeed: Feed {
    var gifs: [Gif] { get }
    func getGif(forURL url: URL) -> Gif?
}

protocol Album {
    var url: URL? { get }
}

protocol AlbumsFeed: Feed {
    var albums: [Album] { get }
}
