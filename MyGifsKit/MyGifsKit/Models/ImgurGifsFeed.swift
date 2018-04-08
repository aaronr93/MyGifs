//
//  ImgurGifFeed.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/18/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import Foundation

final class ImgurGifsFeed: GifFeed {
    var gifs: [Gif] = []
    var url: URL?
    var map: [ArraySlice<Gif>] = []
    
    private var lastFetchCount = 0
    private var eTag = ""
    private var fetchPageInProgress = false
    private let webService: WebService
    
    var numberOfItemsInFeed: Int { return gifs.count }
    private var totalPages: Int { return map.endIndex }
    
    init() {
        webService = WebService()
    }
    
    /**
     Models a request and response object for retrieving gifs belonging to the specified album.
     - Parameters:
       - albumId: A unique identifier for the Imgur album
     */
    convenience init(albumId: String) {
        self.init()
        guard !albumId.isEmpty else { return }
        url = URL.ForImgurAlbumImages(albumId: albumId)
    }
    
    convenience init(username: String) {
        self.init()
        guard !username.isEmpty else { return }
        url = URL.ForImgurAccountImages(username: username)
    }
    
    /**
     Determines if the user has scrolled to the last possible "page" by examining if the
     number of items fetched is less than the usual number of items returned.
     */
    func shouldBatchFetch() -> Bool {
        return !(totalPages > 0 && lastFetchCount < Const.Imgur.MaxResponseCount)
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
    
    private func addHeaders(toRequestWith url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.addValue("Client-ID 0cf6d3195975a95", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func fetchNextPage(numberOfAdditionsCompletion: @escaping (Int, NetworkingErrors?) -> ()) {
        guard var url = self.url else { return }
        url.appendPathComponent("\(totalPages)", isDirectory: false)
        
        let model: Resource<ImgurGifsFeedModel> = webService.getModel(withURL: url)
        webService.load(resource: model, withHeaders: addHeaders) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let response):
                    numberOfAdditionsCompletion(self.parseResult(from: response), nil)
                case .failure(let fail):
                    numberOfAdditionsCompletion(0, fail)
                }
            }
        }
    }
    
    func parseResult(from response: (feed: ImgurGifsFeedModel, eTag: String?)) -> Int {
        self.eTag = response.eTag ?? ""
        
        let gifsFeed = response.feed
        guard gifsFeed.success else { return 0 }
        self.lastFetchCount = gifsFeed.data.count
        
        var gifsToAdd: [Gif] = []
        gifsToAdd = gifsFeed.data.map { ImgurGif(model: $0) }
        
        let indexOfLastElement = max(self.gifs.endIndex-1, 0)
        
        DispatchQueue.main.async {
            self.gifs += gifsToAdd
            let page = self.gifs.suffix(from: indexOfLastElement)
            self.map.append(page)
        }
        
        return gifsFeed.data.count
    }
}

struct ImgurGifsFeedModel: Decodable {
    var data: [ImgurGifModel]
    var success: Bool
    var status: HTTPStatusCode
}
