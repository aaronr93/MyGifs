//
//  AlbumCollectionNode.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/18/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

protocol CollectionNodeTapDelegate: class {
    func didTap(_ item: SendableItem, _ action: TapAction)
}

class AlbumCollectionNode: ASCellNode {
    
    func size() -> CGSize {
        let albumSize = self.albumNode.calculatedSize
        let titleHeight = self.albumTitleNode.calculatedSize.height
        return CGSize(width: 100, height: 100 + titleHeight)
    }
    
    let albumTitleNode = ASTextNode()
    let albumNode: ASNetworkImageNode = {
        let imageNode = ASNetworkImageNode()
        imageNode.contentMode = .scaleAspectFit
        return imageNode
    }()
    
    weak var delegate: CollectionNodeTapDelegate!
    var album: Album!
    
    init(album: Album) {
        super.init()
        self.album = album
        albumNode.url = album.coverUrl
        if let title = album.title {
            albumTitleNode.attributedText = NSAttributedString(string: title)
        }
        self.automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        albumNode.addTarget(self, action: #selector(didTapNode(_:)), forControlEvents: .touchUpInside)
    }
    
    @objc func didTapNode(_ sender: UITapGestureRecognizer? = nil) {
        delegate.didTap(album, .ExpandChildren)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let stack = ASStackLayoutSpec.vertical()
        let thumbnailStack = ASRatioLayoutSpec(ratio: 1, child: albumNode)
        let titleStack = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), child: albumTitleNode)
        stack.children = [thumbnailStack, titleStack]
        return stack
    }
    
}

