//
//  GifCollectionNodeDataSource.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/17/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

class GifCollectionNodeDataSource: NSObject {
    var feed: GifFeed
    weak var delegate: CollectionNodeDataSourceDelegate!
    init(newFeed: GifFeed) {
        feed = newFeed
    }
}

extension GifCollectionNodeDataSource: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int { return 1 }
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return feed.numberOfItemsInFeed
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let gif = feed.gifs[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let node = GifCollectionNode(gif: gif)
            node.gifNode.delegate = self
            return node
        }
        return nodeBlock
    }
}

extension GifCollectionNodeDataSource: ASCollectionDelegate {
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

extension GifCollectionNodeDataSource: ASVideoNodeDelegate {
    func didTap(_ videoNode: ASVideoNode) {
        guard let gifNode = videoNode as? ASGifNode else { return }
        guard let viewableUrl = gifNode.viewableUrl else { return }
        guard let gif = feed.getGif(forURL: viewableUrl) else { return }
        delegate.didTap(gif)
    }
}

