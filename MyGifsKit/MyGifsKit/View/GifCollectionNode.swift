//
//  GifCollectionViewCell.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit
import AVFoundation

class GifCollectionNode: ASCellNode {
    
    let gifNode: ASGifNode = {
        let videoNode = ASGifNode()
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldAutorepeat = true
        videoNode.shouldAutoplay = true
        return videoNode
    }()
    
    init(gif: Gif) {
        super.init()
        DispatchQueue.main.async {
            self.gifNode.asset = AVAsset(url: gif.smallUrl)
        }
        self.gifNode.url = gif.thumbnailImageUrl
        self.gifNode.viewableUrl = gif.viewableUrl
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: 9/16, child: gifNode)
    }
    
}

class ASGifNode: ASVideoNode {
    var viewableUrl: URL?
}
