//
//  GfyCollectionNodeController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit
import MyGifsKit

class GfyCollectionNodeController: ASViewController<ASCollectionNode> {
    
    let username = "aaronr93"
    let numberOfColumns = 3
    let layout: MosaicCollectionViewLayout
    let layoutInspector: MosaicCollectionViewLayoutInspector
    var activityIndicator: UIActivityIndicatorView!
    let collectionNode: ASCollectionNode
    var gfyFeed: GfyFeed
    var feedModelType: FeedModelType = .feedModelTypeGfyUser
    
    init() {
        layout = MosaicCollectionViewLayout()
        layoutInspector = MosaicCollectionViewLayoutInspector()
        layout.numberOfColumns = numberOfColumns
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        switch feedModelType {
        case .feedModelTypeGfyUser:
            gfyFeed = GfyUserFeed(username: username)
            break
        default:
            gfyFeed = GfyUserFeed(username: username)
            break
        }
        super.init(node: collectionNode)
        layout.delegate = self
        node.layoutInspector = layoutInspector
        node.allowsSelection = false
        node.dataSource = self
        node.delegate = self
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        node.leadingScreensForBatching = 2.5
        navigationController?.hidesBarsOnSwipe = true
    }
    
    func setupActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator = activityIndicator
        let bounds = self.node.frame
        var refreshRect = activityIndicator.frame
        refreshRect.origin = CGPoint(x: (bounds.size.width - activityIndicator.frame.size.width) / 2.0, y: (bounds.size.height - activityIndicator.frame.size.height) / 2.0)
        activityIndicator.frame = refreshRect
        self.node.view.addSubview(activityIndicator)
    }
}

extension GfyCollectionNodeController: ASCollectionDataSource, ASCollectionDelegate {
    // MARK: ASCollectionDataSource, ASCollectionDelegate
    
    func shouldBatchFetchForCollectionNode(collectionNode: ASCollectionNode) -> Bool { return true }
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int { return 1 }
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return gfyFeed.numberOfItemsInFeed
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let gif = gfyFeed.gfys[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            return GifCollectionNode(gif: gif)
        }
        return nodeBlock
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        fetchNewBatchWithContext(context)
    }
    
    func fetchNewBatchWithContext(_ context: ASBatchContext?) {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        gfyFeed.updateNewBatch { additions, connectionStatus in
            switch connectionStatus {
            case .connected:
                self.activityIndicator.stopAnimating()
                self.addRowsIntoTableNode(newGfyCount: additions)
                context?.completeBatchFetching(true)
            case .noConnection:
                self.activityIndicator.stopAnimating()
                context?.completeBatchFetching(true)
                break
            }
        }
    }
    
    func addRowsIntoTableNode(newGfyCount newGfys: Int) {
        let indexRange = (gfyFeed.numberOfItemsInFeed - newGfys..<gfyFeed.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
}

extension GfyCollectionNodeController: MosaicCollectionViewLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAt indexPath: IndexPath) -> CGSize {
        return gfyFeed.gfys[indexPath.row].size()
    }
}
