//
//  AlbumCollectionNodeDataSource.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/17/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

class AlbumCollectionNodeDataSource: NSObject {
    var feed: AlbumsFeed
    weak var delegate: CollectionNodeDataSourceDelegate!
    init(newFeed: AlbumsFeed) {
        feed = newFeed
    }
}

extension AlbumCollectionNodeDataSource: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int { return 1 }
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return feed.numberOfItemsInFeed
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let album = feed.albums[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let node = AlbumCollectionNode(album: album)
            node.albumNode.delegate = self
            return node
        }
        return nodeBlock
    }
}

extension AlbumCollectionNodeDataSource: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        delegate.didBeginUpdate(context)
        feed.updateNewBatch { additions, connectionStatus in
            self.delegate.didEndUpdate(context, with: additions, connectionStatus)
        }
    }
    
    func shouldBatchFetchForCollectionNode(collectionNode: ASCollectionNode) -> Bool {
        return true
    }
}

extension AlbumCollectionNodeDataSource: ASNetworkImageNodeDelegate {
    
}


