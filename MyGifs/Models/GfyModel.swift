//
//  GfyModel.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 12/21/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

struct Gfy: Decodable {
    var title: String?
    var miniUrl: URL?
    var mobileUrl: URL?
    var thumb360Url: URL?
    var mp4Url: URL?
    var width: Int?
    var height: Int?
    var tags: [String]?
}
extension Gfy: Hashable {
    var hashValue: Int {
        if let mp4Url = mp4Url {
            return mp4Url.hashValue
        } else {
            return 0
        }
    }
    static func ==(lhs: Gfy, rhs: Gfy) -> Bool {
        if (lhs.mp4Url == rhs.mp4Url) {
            return true
        } else {
            return false
        }
    }
}

struct Tag: Decodable {
    var tag: String?
    var gfycats: [Gfy]?
}

struct UserFeed: Decodable {
    var gfycats: [Gfy]?
    var cursor: String?
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
 var title: String = ""
 var subreddit: String = ""
 var redditId: String = ""
 var redditIdText: String = ""
 */






