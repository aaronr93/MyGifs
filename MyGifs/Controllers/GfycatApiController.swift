//
//  GfycatApiController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

class GfycatApi {
    
    private static let baseURLString = "https://api.gfycat.com"
    
    static func getUserGfycats(user: String, params: Dictionary<String, Any>?, success: @escaping (_: Data) -> Void) {
        GfycatApi.fetchUserGfycats(userId: user, params: params, success: success)
    }
    
    private static func fetchUserGfycats(userId: String, params: Dictionary<String, Any>?, success: @escaping (_: Data) -> Void) {
        let path = "/v1/users/\(userId)/gfycats"
        let url = URL(string: baseURLString + path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)!
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let params = params {
            urlComponents.queryItems = getQueryParams(for: params)
        }
        let session = URLSession(configuration: URLSessionConfiguration.ephemeral, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlComponents.url!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data else {
                print("Error")
                return
            }
            do {
                let obj = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                print(obj)
            } catch {
                
            }
            
            success(data)
        })
        task.resume()
    }
    
    private static func getQueryParams(for dictionary: [AnyHashable: Any]) -> [URLQueryItem] {
        return dictionary.map {
            return URLQueryItem(name: "\($0)", value: "\($1)")
        }
    }
    
}
