//
//  ImgurGifModel.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/14/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import Foundation

final class ImgurGif: Gif {
    var id: String
    var viewableUrl: URL
    var smallUrl: URL
    var fullResUrl: URL
    var thumbnailImageUrl: URL?
    var title: String?
    var width: Int
    var height: Int
    
    init(model: ImgurGifModel) {
        id = model.id
        smallUrl = model.mp4?.addingImgurThumbnailTag(tag: .Small) ?? model.link.addingImgurThumbnailTag(tag: .Small)
        fullResUrl = model.mp4 ?? model.link
        viewableUrl = model.gifv ?? URL.ForImgurImage(imageHash: model.id)!
        title = model.title
        width = model.width
        height = model.height
    }
    
    func size() -> CGSize {
        return CGSize(width: width, height: height)
    }
}

struct ImgurGifModel: Decodable {
    var id: String
    var title: String?
    var description: String?
    var type: String
    var animated: Bool
    var width: Int
    var height: Int
    var size: Int
    var views: Int
    var bandwidth: Int
    var link: URL
    var gifv: URL?
    var mp4: URL?
    var looping: Bool?
    var nsfw: Bool?
    var in_gallery: Bool
}
