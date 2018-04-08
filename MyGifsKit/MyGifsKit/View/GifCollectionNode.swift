//
//  GifCollectionViewCell.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit
import AVFoundation

class GifCollectionNode: ASCellNode, ASVideoNodeDelegate {
    
    func videoNode(_ videoNode: ASVideoNode, willChange state: ASVideoNodePlayerState, to toState: ASVideoNodePlayerState) {
        print("HELLO")
    }
    
    lazy var gifNode: ASGifNode = {
        let videoNode = ASGifNode()
        videoNode.contentMode = .scaleAspectFill
        videoNode.shouldAutorepeat = true
        videoNode.shouldAutoplay = true
        videoNode.muted = true
        videoNode.delegate = self
        return videoNode
    }()
    
    private let assetUrl: URL
    
    init(gif: Gif) {
        self.assetUrl = gif.smallUrl
        super.init()
        self.gifNode.url = gif.thumbnailImageUrl
        self.gifNode.viewableUrl = gif.viewableUrl
        self.automaticallyManagesSubnodes = true
    }
    
    override func didEnterPreloadState() {
        self.gifNode.asset = AVURLAsset(url: assetUrl)
        self.gifNode.asset?.loadValuesAsynchronously(forKeys: ["playable"], completionHandler: {
            var error: NSError? = nil
            let status = self.gifNode.asset?.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded?:
                break
            // Sucessfully loaded. Continue processing.
            case .failed?:
                break
            // Handle error
            case .cancelled?:
                break
            // Terminate processing
            default:
                break
                // Handle all other cases
            }
        })
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: 9/16, child: gifNode)
    }
    
}

class ASGifNode: ASVideoNode {
    var viewableUrl: URL?
}
