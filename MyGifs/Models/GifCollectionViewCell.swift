//
//  GifCollectionViewCell.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import UIKit
import AVFoundation

class GifCollectionViewCell: UICollectionViewCell {
    var gfy: Gfy?
    var thumb: PlayerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Required to align the player to the cell's top left corner
        let frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        thumb = PlayerView(frame: frame)
        if let thumb = thumb {
            thumb.contentMode = UIViewContentMode.scaleAspectFit
            contentView.addSubview(thumb)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
