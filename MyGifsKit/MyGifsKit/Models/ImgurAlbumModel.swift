//
//  ImgurAlbumModel.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/16/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

final class ImgurAlbum: Album {
    var id: String
    var gifs: [Gif] = []
    var coverUrl: URL?
    var coverWidth: Int?
    var coverHeight: Int?
    var viewableUrl: URL
    var title: String?
    
    init(model: ImgurAlbumModel) {
        id = model.id
        if let coverId = model.cover {
            let thumbnailHash = coverId + String(Thumbnail.BigSquare.rawValue)
            coverUrl = URL.ForImgurAlbumCover(imageHash: thumbnailHash)!
        }
        coverWidth = model.cover_width
        coverHeight = model.cover_height
        viewableUrl = URL(string: Const.Imgur.BaseAlbumUrlString + model.id)!
        title = model.title
        if let images = model.images {
            gifs = images.map({ (gifModel: ImgurGifModel) -> Gif in
                return ImgurGif(model: gifModel)
            })
        }
    }
}

struct ImgurAlbumModel: Decodable {
    var id: String
    var title: String?
    var description: String?
    var datetime: Date
    
    var cover: String?
    var cover_width: Int?
    var cover_height: Int?
    
    var account_url: String?
    var account_id: Int?
    
    var privacy: ImgurAlbumPrivacy?
    var layout: ImgurFeedLayout?
    var views: Int
    var link: URL
    var favorite: Bool
    var nsfw: Bool?
    var section: String?
    var order: Int
    var deletehash: String?
    var images_count: Int
    
    var images: [ImgurGifModel]?
    
    var in_gallery: Bool
    var is_ad: Bool
}

enum ImgurAlbumPrivacy: String, Decodable {
    case Public = "public"
    case Private = "private"
}

enum ImgurFeedLayout: String, Decodable {
    case Blog = "blog"
}

