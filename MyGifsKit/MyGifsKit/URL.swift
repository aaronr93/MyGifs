//
//  URL.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/31/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

public extension URL {
    
    static func URLForUser(username: String) -> URL? {
        guard !username.isEmpty else { return nil }
        let urlString = Const.Gfy.baseApiUrlString + Const.Gfy.userFeed + "/" + username + Const.Gfy.gfycatsFeed
        return URL(string: urlString)
    }
    
    static func URLForTag(tagname: String) -> URL? {
        guard !tagname.isEmpty else { return nil }
        let tagsFeedBaseUrl = URL(string: Const.Gfy.baseApiUrlString + Const.Gfy.tagsFeed)
        return tagsFeedBaseUrl?.addQueryParams([Const.Gfy.Param.tagName:tagname])
    }
    
    static func URLForSearch(searchStr: String) -> URL? {
        guard !searchStr.isEmpty else { return nil }
        let tagsFeedBaseUrl = URL(string: Const.Gfy.baseApiUrlString + Const.Gfy.gfycatsFeed + Const.Gfy.searchFeed)
        return tagsFeedBaseUrl?.addQueryParams([Const.Gfy.Param.searchText:searchStr])
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
