//
//  GfyModel.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 12/21/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

final public class Gfy: Gif {
    public var smallUrl: URL
    public var fullResUrl: URL
    public var thumbnailImageUrl: URL?
    public var title: String?
    public var width: Int
    public var height: Int
    
    init(model: GfyModel) {
        if let miniUrl = model.miniUrl {
            self.smallUrl = miniUrl
        } else if let mobileUrl = model.mobileUrl {
            self.smallUrl = mobileUrl
        } else {
            self.smallUrl = model.mp4Url
        }
        self.thumbnailImageUrl = model.miniPosterUrl
        self.fullResUrl = URL(string: Const.Gfy.baseUrlString + model.gfyId)!
        self.title = model.title
        self.width = model.width
        self.height = model.height
    }
    
    public func size() -> CGSize {
        return CGSize(width: width, height: height)
    }
}
extension Gfy: Hashable {
    public var hashValue: Int {
        return fullResUrl.hashValue
    }
    public static func ==(lhs: Gfy, rhs: Gfy) -> Bool {
        if (lhs.fullResUrl == rhs.fullResUrl) {
            return true
        } else {
            return false
        }
    }
}

struct GfyModel: Decodable {
    var gfyId: String
    var title: String?
    var miniUrl: URL?
    var mobileUrl: URL?
    var mp4Url: URL
    var miniPosterUrl: URL
    var width: Int
    var height: Int
    var tags: [String]?
    
//    var gfyNumber: Int
//    var webmUrl: URL?
//    var gfyUrl: URL?
//    var mobilePosterUrl: URL?
//    var posterUrl: URL?
//    var thumb360Url: URL?
//    var thumb360PosterUrl: URL?
//    var thumb100PosterUrl: URL?
//    var max5mbGif: URL?
//    var max2mbGif: URL?
//    var mjpgUrl: URL?
//    var frameRate: Int
//    var numFrames: Int
//    var mp4Size: Int
//    var webmSize: Int
//    var gfySize: Int
//    var createDate: String?
//    var nsfw: String?
//    var likes: Int
//    var published: Int
//    var dislikes: Int
//    var extraLemmas: String?
//    var md5: String?
//    var views: Int
//    var userName: String?
//    var gfyName: String?
//    var subreddit: String?
//    var redditId: String?
//    var redditIdText: String?
}
