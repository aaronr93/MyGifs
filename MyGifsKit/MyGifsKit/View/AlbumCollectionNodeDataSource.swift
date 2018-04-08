//
//  AlbumCollectionNodeDataSource.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/17/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

protocol CollectionNodeDataSourceDelegate: class {
    func didTap(_ item: SendableItem, _ action: TapAction)
    func didBeginUpdate(_ context: ASBatchContext?)
    func didEndUpdate(_ context: ASBatchContext?, with additions: Int, _ connectionStatus: InternetStatus)
}

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
            node.delegate = self
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
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return feed.shouldBatchFetch()
    }
}

extension AlbumCollectionNodeDataSource: CollectionNodeTapDelegate {
    func didTap(_ item: SendableItem, _ action: TapAction) {
        delegate.didTap(item, action)
    }
}


