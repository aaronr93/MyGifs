//
//  PlayerView.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 12/2/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

/// A view that manages displaying a `GifPlayer`
class PlayerView: UIView {
    var player: GifPlayer? {
        get {
            return playerLayer.player as? GifPlayer
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
}
