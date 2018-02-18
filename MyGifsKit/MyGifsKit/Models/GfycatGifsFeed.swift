//
//  GfycatUserFeedModel.swift
//  MyGifs
//
//  Created by Aaron Rosenberger on 12/30/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation

final class GfyFeed: GifFeed {
    var gifs: [Gif] = []
    var url: URL?
    private var cursor: String?
    private var totalPagesSoFar: Int = 0
    private var fetchPageInProgress: Bool = false
    
    init(username: String) {
        url = URL.ForGfycatUser(username: username)
    }
    
    func getGif(forURL url: URL) -> Gif? {
        return gifs.first(where: { $0.viewableUrl == url })
    }
    
    var numberOfItemsInFeed: Int { return gifs.count }

    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ()) {
        guard !fetchPageInProgress else { return }
        
        fetchPageInProgress = true
        fetchNextPage(replaceData: false) { [unowned self] additions, errors in
            self.fetchPageInProgress = false
            
            if let error = errors {
                switch error {
                case .noInternetConnection:
                    additionsAndConnectionStatusCompletion(0, .noConnection)
                default:
                    additionsAndConnectionStatusCompletion(0, .connected)
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
        
        let webService = WebService()
        let model: Resource<GfyUserFeedModel> = webService.getModel(withURL: urlWithCursor)
        webService.load(resource: model) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let userFeed):
                    self.totalPagesSoFar += 1
                    self.cursor = userFeed.cursor
                    
                    var gifs: [Gif] = []
                    for gfyModel in userFeed.gfycats {
                        gifs.append(Gfy(model: gfyModel))
                    }
                    
                    DispatchQueue.main.async {
                        if replaceData {
                            self.gifs = gifs
                        } else {
                            self.gifs += gifs
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

struct GfyTagFeedModel: Decodable {
    var tag: String
    var gfycats: [GfyModel]
    var cursor: String?
    var digest: String?
    var tagText: String?
}

