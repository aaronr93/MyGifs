//
//  GfyModel.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 12/21/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation
import AVFoundation

final public class Gfy: Gif {
    public var thumbnailAsset: AVAsset
    public var thumbnailUrl: URL
    var imageUrl: URL
    var originalUrl: URL
    var title: String?
    public var width: Int
    public var height: Int
    
    init(model: GfyModel) {
        if let miniUrl = model.miniUrl {
            self.thumbnailUrl = miniUrl
        } else if let mobileUrl = model.mobileUrl {
            self.thumbnailUrl = mobileUrl
        } else {
            self.thumbnailUrl = model.mp4Url
        }
        self.imageUrl = model.miniPosterUrl
        self.originalUrl = model.mp4Url
        self.title = model.title
        self.width = model.width
        self.height = model.height
        self.thumbnailAsset = AVAsset(url: thumbnailUrl)
    }
    
    public func size() -> CGSize {
        return CGSize(width: width, height: height)
    }
}
extension Gfy: Hashable {
    public var hashValue: Int {
        return originalUrl.hashValue
    }
    public static func ==(lhs: Gfy, rhs: Gfy) -> Bool {
        if (lhs.originalUrl == rhs.originalUrl) {
            return true
        } else {
            return false
        }
    }
}

struct GfyModel: Decodable {
    var title: String?
    var miniUrl: URL?
    var mobileUrl: URL?
    var mp4Url: URL
    var miniPosterUrl: URL
    var width: Int
    var height: Int
    var tags: [String]?
}

/*
 var gfyId: String = ""
 var gfyNumber: Int = 0
 var webmUrl: String = ""
 var gfyUrl: String = ""
 var mobileUrl: String = ""
 var mobilePosterUrl: String = ""
 var posterUrl: String = ""
 var thumb360Url: String = ""
 var thumb360PosterUrl: String = ""
 var thumb100PosterUrl: String = ""
 var miniPosterUrl: String = ""
 var max5mbGif: String = ""
 var max2mbGif: String = ""
 var mjpgUrl: String = ""
 var width: Int = 0
 var height: Int = 0
 var frameRate: Int = 0
 var numFrames: Int = 0
 var mp4Size: Int = 0
 var webmSize: Int = 0
 var gfySize: Int = 0
 var createDate: String = ""
 var nsfw: String = ""
 var mp4Url: String = ""
 var likes: Int = 0
 var published: Int = 0
 var dislikes: Int = 0
 var extraLemmas: String = ""
 var md5: String = ""
 var views: Int = 0
 var userName: String = ""
 var gfyName: String = ""
 var subreddit: String = ""
 var redditId: String = ""
 var redditIdText: String = ""
 */






