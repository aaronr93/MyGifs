//
//  ImgurAccountAlbumsModel.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/14/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

final class ImgurAccountAlbums: AlbumsFeed {
    var albums: [Album] = []
    var numberOfItemsInFeed: Int = 0
    var fetchPageInProgress = false
    var url: URL?
    
    init(username: String) {
        guard !username.isEmpty else { return }
        url = URL.ForImgurAccountAlbums(username: username)
    }
    
    func getModel(withURL: URL) -> Resource<ImgurAccountAlbumsFeedModel> {
        let parse = Resource<ImgurAccountAlbumsFeedModel>(url: withURL, parseJSON: { data in
            guard let model = try? JSONDecoder().decode(ImgurAccountAlbumsFeedModel.self, from: data) else {
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
                default:
                    additionsAndConnectionStatusCompletion(0, .connected)
                }
            } else {
                additionsAndConnectionStatusCompletion(additions, .connected)
            }
        }
    }
    
    private func fetchNextPage(replaceData: Bool, numberOfAdditionsCompletion: @escaping (Int, NetworkingErrors?) -> ()) {
        guard let url = self.url else { return }
        
        let webService = WebService()
        let model: Resource<ImgurAccountAlbumsFeedModel> = webService.getModel(withURL: url)
        webService.load(resource: model) { [unowned self] result in
            DispatchQueue.global().async {
                switch result {
                case .success(let albumsFeed):
                    guard albumsFeed.success else {
                        numberOfAdditionsCompletion(albumsFeed.data.count, nil)
                        return
                    }
                    
                    var albums: [Album] = []
                    for albumModel in albumsFeed.data {
                        albums.append(ImgurAlbum(model: albumModel))
                    }
                    DispatchQueue.main.async {
                        if replaceData {
                            self.albums = albums
                        } else {
                            self.albums += albums
                        }
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
