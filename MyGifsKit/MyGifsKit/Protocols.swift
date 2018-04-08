//
//  Feed.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public enum TapAction {
    case SendTextMessage
    case ShareMenu
    case ExpandChildren
}

protocol RequestHeaders: Encodable {
    var Authorization: String? { get }
}

protocol ResponseHeaders: Decodable {
    var ContentType: eResponseContentType? { get }
}
enum eResponseContentType: String, Decodable {
    case JSON = "application/json"
    case XML = "application/xml"
}

public protocol SendableItem {
    var viewableUrl: URL { get }
    var title: String? { get }
    var id: String { get }
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
    func shouldBatchFetch() -> Bool
    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ())
}

protocol GifFeed: Feed {
    var gifs: [Gif] { get }
}
extension GifFeed {
    func getGif(forURL url: URL) -> Gif? {
        return gifs.first(where: { $0.viewableUrl == url })
    }
}

protocol Album: SendableItem {
    var id: String { get }
    var gifs: [Gif] { get }
    var coverUrl: URL? { get }
    var coverWidth: Int? { get }
    var coverHeight: Int? { get }
}
extension Album {
    func coverSize() -> CGSize? {
        guard coverUrl != nil, (coverWidth != nil && coverHeight != nil) else { return nil }
        if let width = coverWidth, let height = coverHeight {
            return CGSize(width: width, height: height)
        } else if let width = coverWidth {
            return CGSize(width: width, height: width)
        } else if let height = coverHeight {
            return CGSize(width: height, height: height)
        }
        return nil
    }
}

protocol AlbumsFeed: Feed {
    var albums: [Album] { get }
}
