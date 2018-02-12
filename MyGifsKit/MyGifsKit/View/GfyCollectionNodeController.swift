//
//  GfyCollectionNodeController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

public protocol GfyCollectionDelegate: class {
    func didTap(_ gifUrlString: String)
}

public enum FeedModelType {
    case feedModelTypeGfyUser
    case feedModelTypeGfyTag
}

public class GfyCollectionNodeController: ASViewController<ASCollectionNode> {
    var username = "aaronr93"
    var numberOfColumns = 1
    var loadingScreensForBatching: CGFloat = 2.5
    public var feedModelType: FeedModelType = .feedModelTypeGfyUser
    private var gfyFeed: GfyFeed
    
    private let layout: MosaicCollectionViewLayout
    private let layoutInspector: MosaicCollectionViewLayoutInspector
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    
    weak public var delegate: GfyCollectionDelegate?
    
    public init() {
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
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        node.leadingScreensForBatching = loadingScreensForBatching
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
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int { return 1 }
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return gfyFeed.numberOfItemsInFeed
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let gif = gfyFeed.gfys[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let node = GifCollectionNode(gif: gif)
            node.gifNode.delegate = self
            return node
        }
        return nodeBlock
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
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

extension GfyCollectionNodeController: ASVideoNodeDelegate {
    public func didTap(_ videoNode: ASVideoNode) {
        guard let gifNode = videoNode as? ASGifNode else { return }
        guard let gifUrlString = gifNode.gifUrlString else { return }
        delegate?.didTap(gifUrlString)
    }
}
