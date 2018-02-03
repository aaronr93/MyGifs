//
//  GifCollectionViewCell.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit
import AVFoundation
import MyGifsKit

class GifCollectionNode: ASCellNode {
    
    let gifNode: ASGifNode = {
        let videoNode = ASGifNode()
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldAutorepeat = true
        videoNode.shouldAutoplay = true
        return videoNode
    }()
    
    init(gif: Gfy) {
        super.init()
        DispatchQueue.main.async {
            self.gifNode.asset = AVAsset(url: gif.smallUrl)
        }
        self.gifNode.url = gif.imageUrl
        
        
        self.gifNode.gifUrlString = gif.fullResUrl.absoluteString
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: 9/16, child: gifNode)
    }
    
}

class ASGifNode: ASVideoNode {
    public var gifUrlString: String?
}
