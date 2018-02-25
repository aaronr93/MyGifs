//
//  ImgurAccountAlbumsModel.swift
//  MyalbumsKit
//
//  Created by Aaron Rosenberger on 2/14/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

final class ImgurAccountAlbums: AlbumsFeed {
    var albums: [Album] = []
    var url: URL?
    var map: [ArraySlice<Album>] = []
    
    private var lastFetchCount = 0
    private var eTag = ""
    private var fetchPageInProgress = false
    private let webService: WebService
    
    var numberOfItemsInFeed: Int { return albums.count }
    private var totalPages: Int { return map.endIndex }
    
    init(username: String) {
        webService = WebService()
        guard !username.isEmpty else { return }
        url = URL.ForImgurAccountAlbums(username: username)
    }
    
    func shouldBatchFetch() -> Bool {
        return !(totalPages > 0 && lastFetchCount < Const.Imgur.MaxResponseCount)
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
                default:
                    additionsAndConnectionStatusCompletion(0, .connected)
                }
            } else {
                additionsAndConnectionStatusCompletion(additions, .connected)
            }
        }
    }
    
    private func fetchNextPage(replaceData: Bool, numberOfAdditionsCompletion: @escaping (Int, NetworkingErrors?) -> ()) {
        guard var url = self.url else { return }
        url.appendPathComponent("\(totalPages)", isDirectory: false)
        
        let model: Resource<ImgurAccountAlbumsFeedModel> = webService.getModel(withURL: url)
        webService.load(resource: model) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let response):
                    let albumsFeed = response.feed
                    self.eTag = response.eTag ?? ""
                    
                    guard albumsFeed.success else {
                        numberOfAdditionsCompletion(0, nil)
                        return
                    }
                    
                    var albumsToAdd: [Album] = []
                    albumsToAdd = albumsFeed.data.map({ (albumModel: ImgurAlbumModel) -> ImgurAlbum in
                        return ImgurAlbum(model: albumModel)
                    })
                    self.lastFetchCount = albumsToAdd.count
                    
                    let indexOfLastElement = max(self.albums.endIndex-1, 0)
                    DispatchQueue.main.async {
                        if replaceData {
                            self.albums = albumsToAdd
                        } else {
                            self.albums += albumsToAdd
                        }
                        let page = self.albums.suffix(from: indexOfLastElement)
                        self.map.append(page)
                        numberOfAdditionsCompletion(albumsFeed.data.count, nil)
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

struct ImgurAccountAlbumsFeedModel: Decodable {
    var data: [ImgurAlbumModel]
    var success: Bool
    var status: HTTPStatusCode
}
