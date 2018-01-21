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
    
    let gifNode: ASVideoNode = {
        let videoNode = ASVideoNode()
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldAutorepeat = true
        videoNode.shouldAutoplay = true
        return videoNode
    }()
    
    init(gif: Gfy) {
        super.init()
        DispatchQueue.main.async {
            self.gifNode.asset = gif.thumbnailAsset
        }
        //self.gifNode.style.maxWidth = ASDimension(unit: ASDimensionUnit.points, value: CGFloat(gif.width / 4))
        //self.gifNode.style.maxHeight = ASDimension(unit: ASDimensionUnit.points, value: CGFloat(gif.height / 4))
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: 9/16, child: gifNode)
    }
    
}
