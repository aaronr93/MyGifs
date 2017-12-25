//
//  GifPlayer.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 12/17/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation
import AVFoundation

class GifPlayer: AVQueuePlayer {
    
    var playerLooper: AVPlayerLooper?

    override init(url URL: URL) {
        super.init(url: URL)
        if let playerItem = self.currentItem {
            playerLooper = AVPlayerLooper(player: self, templateItem: playerItem)
        }
    }
    
//    override init(url URL: URL) {
//        super.init(playerItem: AVPlayerItem(url: URL))
//    }
    
    override init(playerItem item: AVPlayerItem?) {
        super.init(playerItem: item)
    }
    
    override init() {
        super.init()
    }
    
}

