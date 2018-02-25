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
        imageNode.contentMode = .scaleAspectFit
        return imageNode
    }()
    
    init(album: Album) {
        super.init()
        albumNode.url = album.coverUrl
        if let title = album.title {
            albumTitleNode.attributedText = NSAttributedString(string: title)
        }
        self.automaticallyManagesSubnodes = true
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        let thumbnailStack = ASRatioLayoutSpec(ratio: 1, child: albumNode)
        let titleStack = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: albumTitleNode)
        stack.children = [thumbnailStack, titleStack]
        return stack
    }
    
}

