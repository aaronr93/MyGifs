//
//  AlbumCollectionNode.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/18/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

class AlbumCollectionNode: ASCellNode {
    
    let albumTitleNode = ASTextNode()
    let albumNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFill
        return imageNode
    }()
    
    init(album: Album) {
        super.init()
        albumNode.url = album.viewableUrl
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASRatioLayoutSpec(ratio: 1, child: albumNode)
    }
    
}

