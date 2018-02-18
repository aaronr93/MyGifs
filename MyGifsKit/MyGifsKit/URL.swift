//
//  URL.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

extension URL {
    static func ForGfycatUser(username: String) -> URL? {
        guard !username.isEmpty else { return nil }
        let urlString = Const.Gfy.baseApiUrlString + Const.Gfy.userFeed + "/" + username + Const.Gfy.gfycatsFeed
        return URL(string: urlString)
    }
    
    static func ForGfycatTag(tagname: String) -> URL? {
        guard !tagname.isEmpty else { return nil }
        let tagsFeedBaseUrl = URL(string: Const.Gfy.baseApiUrlString + Const.Gfy.tagsFeed)
        return tagsFeedBaseUrl?.addQueryParams([Const.Gfy.Param.tagName:tagname])
    }
    
    static func ForGfycatSearch(searchStr: String) -> URL? {
        guard !searchStr.isEmpty else { return nil }
        let tagsFeedBaseUrl = URL(string: Const.Gfy.baseApiUrlString + Const.Gfy.gfycatsFeed + Const.Gfy.searchFeed)
        return tagsFeedBaseUrl?.addQueryParams([Const.Gfy.Param.searchText:searchStr])
    }
    
    static func ForImgurAccountAlbums(username: String) -> URL? {
        guard !username.isEmpty else { return nil }
        let urlString = Const.Imgur.BaseApiUrlString + Const.Imgur.Endpoint.Account + username + Const.Imgur.Endpoint.Albums
        return URL(string: urlString)
    }
    
    static func ForImgurAlbumImages(albumId: String) -> URL? {
        guard !albumId.isEmpty else { return nil }
        let urlString = Const.Imgur.BaseApiUrlString + Const.Imgur.Endpoint.Album + albumId + Const.Imgur.Endpoint.Images
        return URL(string: urlString)
    }
    
    static func ForImgurImage(imageHash: String) -> URL? {
        guard !imageHash.isEmpty else { return nil }
        let urlString = Const.Imgur.BaseApiUrlString + Const.Imgur.Endpoint.Image + imageHash
        return URL(string: urlString)
    }
    
    func addQueryParams(_ params: Dictionary<String, String>) -> URL {
        guard !params.isEmpty else { return self }
        let queryItems: [URLQueryItem] = params.map { return URLQueryItem(name: $0.key, value: $0.value) }
        return self.addQueryParams(queryItems)
    }
    
    func addQueryParams(_ params: [URLQueryItem]) -> URL {
        guard !params.isEmpty else { return self }
        let urlComponents = NSURLComponents.init(url: self, resolvingAgainstBaseURL: false)
        guard urlComponents != nil else { return self }
        if urlComponents?.queryItems == nil {
            urlComponents?.queryItems = [];
        }
        urlComponents?.queryItems?.append(contentsOf: params)
        if let newUrl = urlComponents?.url {
            return newUrl
        } else {
            return self
        }
    }
}
