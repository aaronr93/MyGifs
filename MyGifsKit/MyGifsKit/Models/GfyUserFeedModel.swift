//
//  GfycatUserFeedModel.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/30/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

final public class GfyUserFeed: GfyFeed {
    public var gfys: [Gif] = []
    private var cursor: String?
    private var url: URL?
    private var totalPagesSoFar: Int = 0
    private var fetchPageInProgress: Bool = false
    
    public init(username: String) {
        url = URL.URLForUser(username: username)
    }
    
    public var numberOfItemsInFeed: Int { return gfys.count }
    
    func parseGfyUserFeed(withURL: URL) -> Resource<GfyUserFeedModel> {
        let parse = Resource<GfyUserFeedModel>(url: withURL, parseJSON: { data in
            guard let model = try? JSONDecoder().decode(GfyUserFeedModel.self, from: data) else {
                return .failure(.errorParsingJSON)
            }
            return .success(model)
        })
        return parse
    }

    public func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ()) {
        guard !fetchPageInProgress else { return }
        
        fetchPageInProgress = true
        fetchNextPage(replaceData: false) { [unowned self] additions, errors in
            self.fetchPageInProgress = false
            
            if let error = errors {
                switch error {
                case .noInternetConnection:
                    additionsAndConnectionStatusCompletion(0, .noConnection)
                default: additionsAndConnectionStatusCompletion(0, .connected)
                }
            } else {
                additionsAndConnectionStatusCompletion(additions, .connected)
            }
        }
    }
    
    private func fetchNextPage(replaceData: Bool, numberOfAdditionsCompletion: @escaping (Int, NetworkingErrors?) -> ()) {
        if totalPagesSoFar > 0, cursor == "" {
            DispatchQueue.main.async {
                return numberOfAdditionsCompletion(0, .customError("No pages left to parse"))
            }
        }
        
        guard self.url != nil else { return }
        
        var urlWithCursor = self.url!
        if let cursorValue = self.cursor, self.url != nil {
            urlWithCursor = self.url!.addQueryParams([URLQueryItem.init(name: Const.Gfy.cursorKey, value: cursorValue)])
        }
        
        WebService().load(resource: parseGfyUserFeed(withURL: urlWithCursor)) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let userFeed):
                    self.totalPagesSoFar += 1
                    self.cursor = userFeed.cursor
                    
                    var gfys: [Gif] = []
                    for gfyModel in userFeed.gfycats {
                        gfys.append(Gfy(model: gfyModel))
                    }
                    
                    DispatchQueue.main.async {
                        if replaceData {
                            self.gfys = gfys
                        } else {
                            self.gfys += gfys
                        }
                        
                        numberOfAdditionsCompletion(userFeed.gfycats.count, nil)
                    }
                case .failure(let fail):
                    print(fail)
                    DispatchQueue.main.async {
                        numberOfAdditionsCompletion(0, fail)
                    }
                }
            }
        }
    }
}

struct GfyUserFeedModel: Decodable {
    var gfycats: [GfyModel] = []
    var cursor: String?
}

public enum InternetStatus {
    case connected
    case noConnection
}

