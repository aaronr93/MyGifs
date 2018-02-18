//
//  ImgurGifModel.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/14/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import Foundation

final class ImgurGif: Gif {
    var viewableUrl: URL
    var smallUrl: URL
    var fullResUrl: URL
    var thumbnailImageUrl: URL?
    var title: String?
    var width: Int
    var height: Int
    
    init(model: ImgurGifModel) {
        if let gifv = model.gifv {
            smallUrl = gifv
            fullResUrl = gifv
        } else if let mp4 = model.mp4 {
            smallUrl = mp4
            fullResUrl = mp4
        } else {
            smallUrl = model.link
            fullResUrl = model.link
        }
        self.viewableUrl = URL.ForImgurImage(imageHash: model.id)!
        self.title = model.title
        self.width = model.width
        self.height = model.height
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
