//
//  GfycatUserFeedModel.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/30/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

final class GfyUserFeed: GfyFeed {
    var gfys: [Gfy] = []
    private var cursor: String?
    
    private var url: URL
    private var totalPagesSoFar: Int = 0
    private var fetchPageInProgress: Bool = false
    
    init(username: String) {
        url = URL.URLForUser(username: username)
    }
    
    var numberOfItemsInFeed: Int { return gfys.count }
    
    func parseGfyUserFeed(withURL: URL) -> Resource<GfyUserFeedModel> {
        let parse = Resource<GfyUserFeedModel>(url: withURL, parseJSON: { data in
            guard let model = try? JSONDecoder().decode(GfyUserFeedModel.self, from: data) else {
                return .failure(.errorParsingJSON)
            }
            return .success(model)
        })
        return parse
    }

    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ()) {
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
        if totalPagesSoFar > 0, cursor == nil {
            DispatchQueue.main.async {
                return numberOfAdditionsCompletion(0, .customError("No pages left to parse"))
            }
        }
        
        WebService().load(resource: parseGfyUserFeed(withURL: url)) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let userFeed):
                    self.totalPagesSoFar += 1
                    self.cursor = userFeed.cursor
                    
                    var gfys: [Gfy] = []
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

enum InternetStatus {
    case connected
    case noConnection
}

