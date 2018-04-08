//
//  Constants.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

struct Const {
    #if DEBUG
        static let debugMode = true
    #else
        static let debugMode = false
    #endif
    struct Gfy {
        static private let apiVersion = "/v1"
        static private let testApiVersion = "/v1test"
        static let cursorKey = "cursor"
        static let baseApiUrlString = "https://api.gfycat.com" +
            (Const.debugMode ? Const.Gfy.testApiVersion : Const.Gfy.apiVersion)
        static let baseUrlString = "https://gfycat.com/"
        static let userFeed = "/users"
        static let selfFeed = "/me"
        static let gfycatsFeed = "/gfycats"
        static let tagsFeed = "/reactions/populated"
        static let searchFeed = "/search"
        static let trendingFeed = "/trending"
        static let followsFeed = Const.Gfy.selfFeed + "/follows"
        struct Param {
            static let tagName = "tagName"
            static let searchText = "search_text"
            static let folderName = "folderName"
            static let gfyCount = "gfyCount"
            static let count = "count"
        }
    }
    struct Imgur {
        static let BaseApiUrlString = "https://api.imgur.com/3"
        static let BaseImageUrlString = "https://i.imgur.com/"
        static let BaseAlbumUrlString = "https://imgur.com/a/"
        static let MaxResponseCount = 50
        struct Endpoint {
            static let Account = "/account/"
            static let Album = "/album/"
            static let Albums = "/albums/"
            static let Image = "/image/"
            static let Images = "/images/"
        }
        struct Extension {
            static let Image = ".jpg"
            static let Gif = ".gifv"
        }
    }
    static let assetKeys = [
        "playable",
        "readable",
        "creationDate",
        "tracks",
        "metadata",
        "commonMetadata",
        "lyrics",
        "compatibleWithAirPlayVideo",
        "compatibleWithSavedPhotosAlbum",
        "preferredMediaSelection"
    ]
}

enum Thumbnail: Character {
    case SmallSquare = "s"    // 90x90
    case BigSquare = "b"      // 160x160
    case Small = "t"          // 160x160
    case Medium = "m"         // 320x320
    case Large = "l"          // 640x640
    case Huge = "h"           // 1024x1024
}

