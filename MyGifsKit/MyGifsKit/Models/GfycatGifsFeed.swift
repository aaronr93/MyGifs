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
    
    var map: [(key: String, gifs: ArraySlice<Gif>)] = []
    
    private var cursor: String = ""
    private var totalPagesSoFar: Int = 0
    private var fetchPageInProgress: Bool = false
    private let webService: WebService
    var numberOfItemsInFeed: Int { return gifs.count }
    
    init() {
        webService = WebService()
    }
    
    /**
     Models a request and response object for retrieving gfys belonging to the specified user.
     - Parameters:
       - username: A Gfycat-registered username whose gifs are fetched
     */
    convenience init(username: String) {
        self.init()
        url = URL.ForGfycatUser(username: username)
    }

    func updateNewBatch(additionsAndConnectionStatusCompletion: @escaping (Int, InternetStatus) -> ()) {
        guard !fetchPageInProgress else { return }
        
        fetchPageInProgress = true
        fetchNextPage() { [unowned self] additions, errors in
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
    
    func shouldBatchFetch() -> Bool {
        return !(totalPagesSoFar > 0 && cursor.isEmpty)
    }
    
    private func fetchNextPage(numberOfAdditionsCompletion: @escaping (Int, NetworkingErrors?) -> ()) {
        guard var batchUrl = self.url, shouldBatchFetch() else {
            numberOfAdditionsCompletion(0, .dataReturnedNil)
            return
        }
        if !cursor.isEmpty {
            batchUrl = batchUrl.addQueryParams([URLQueryItem.init(name: Const.Gfy.cursorKey, value: cursor)])
        }
        
        let model: Resource<GfyUserFeedModel> = webService.getModel(withURL: batchUrl)
        webService.load(resource: model, withHeaders: nil) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let response):
                    let feed = response.feed
                    self.totalPagesSoFar += 1
                    self.cursor = feed.cursor ?? ""
                    
                    var gifsToAdd: [Gif] = []
                    gifsToAdd = feed.gfycats.map({ (gifModel: GfyModel) -> Gif in
                        return Gfy(model: gifModel)
                    })
                    
                    let indexOfLastElement = max(self.gifs.endIndex-1, 0)
                    DispatchQueue.main.async {
                        self.gifs += gifsToAdd
                        let page = (self.cursor, gifs: self.gifs.suffix(from: indexOfLastElement))
                        self.map.append(page)
                    }
                    numberOfAdditionsCompletion(feed.gfycats.count, nil)
                case .failure(let fail):
                    numberOfAdditionsCompletion(0, fail)
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

