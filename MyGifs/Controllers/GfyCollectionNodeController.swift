//
//  GfyCollectionNodeController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

fileprivate let gfyReuseIdentifier = "gfy"
fileprivate let loopSafety = 100
fileprivate let kMaxGifs = 20

fileprivate let itemsPerRow: CGFloat = 2.0
fileprivate let sectionInsets = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)

class GfyCollectionNodeController: ASViewController<ASCollectionNode>, MosaicCollectionViewLayoutDelegate {
    
    //let dataController = DataController()
    var i = 0
    let layout = UICollectionViewFlowLayout() //MosaicCollectionViewLayout()
    let collectionNode: ASCollectionNode
    var gfyFeed: GfyFeed
    var feedModelType: FeedModelType = .feedModelTypeGfyUser
    var activityIndicator: UIActivityIndicatorView!
    
    init() {
//        layout.minimumInteritemSpacing = 1
//        layout.minimumLineSpacing = 1
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        switch feedModelType {
        case .feedModelTypeGfyUser:
            gfyFeed = GfyUserFeed(username: "aaronr93")
            break
        default:
            gfyFeed = GfyUserFeed(username: "aaronr93")
            break
        }
        super.init(node: collectionNode)
//        layout.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        node.allowsSelection = false
        node.dataSource = self
        node.delegate = self
        node.leadingScreensForBatching = 2.5
        navigationController?.hidesBarsOnSwipe = true
    }
    
    // MARK: Helper functions
    func setupActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator = activityIndicator
        let bounds = self.node.frame
        var refreshRect = activityIndicator.frame
        refreshRect.origin = CGPoint(x: (bounds.size.width - activityIndicator.frame.size.width) / 2.0, y: (bounds.size.height - activityIndicator.frame.size.height) / 2.0)
        activityIndicator.frame = refreshRect
        self.node.view.addSubview(activityIndicator)
    }
    
    var screenSizeForWidth: CGSize = {
        let screenRect = UIScreen.main.bounds
        let screenScale = UIScreen.main.scale
        return CGSize(width: screenRect.size.width * screenScale, height: screenRect.size.width * screenScale)
    }()
    
    func fetchNewBatchWithContext(_ context: ASBatchContext?) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        gfyFeed.updateNewBatch { additions, connectionStatus in
            switch connectionStatus {
            case .connected:
                self.activityIndicator.stopAnimating()
                self.addRowsIntoTableNode(newGfyCount: additions)
                context?.completeBatchFetching(true)
            case .noConnection:
                self.activityIndicator.stopAnimating()
                if context != nil {
                    context!.completeBatchFetching(true)
                }
                break
            }
        }
    }
    
    func finishedFetchingNewBatch(additions: Int) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
        self.addRowsIntoTableNode(newGfyCount: additions)
    }
    
    func addRowsIntoTableNode(newGfyCount newGfys: Int) {
        let indexRange = (gfyFeed.numberOfItemsInFeed - newGfys..<gfyFeed.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        return gfyFeed.gfys[originalItemSizeAtIndexPath.item].size()
    }
}

extension GfyCollectionNodeController: ASCollectionDataSource, ASCollectionDelegate {
    // MARK: ASCollectionDataSource
    
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
}
