//
//  CollectionNodeController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

public protocol GifCollectionDelegate: class {
    func didTap(_ item: SendableItem)
}

enum FeedModelType {
    case feedModelTypeGfyUser
    case feedModelTypeGfyTag
}

public class CollectionNodeController: ASViewController<ASCollectionNode> {
    
    var numberOfColumns: Int {
        didSet { layout.numberOfColumns = numberOfColumns }
    }
    
    var loadingScreensForBatching: CGFloat {
        didSet { node.leadingScreensForBatching = loadingScreensForBatching }
    }
    
    private var feed: GifFeed
    
    private let layout: MosaicCollectionViewLayout
    private let layoutInspector: MosaicCollectionViewLayoutInspector
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    private var gifDataSource: CollectionNodeGifDataSource!
    
    weak public var delegate: GifCollectionDelegate?
    
    public init() {
        layout = MosaicCollectionViewLayout()
        layoutInspector = MosaicCollectionViewLayoutInspector()
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        numberOfColumns = 1
        loadingScreensForBatching = 2.5
        
        feed = GfyFeed(username: "aaronr93")
        gifDataSource = CollectionNodeGifDataSource(newFeed: feed)
        
        super.init(node: collectionNode)
        layout.delegate = self
        node.layoutInspector = layoutInspector
        node.allowsSelection = false
        
        node.dataSource = gifDataSource
        node.delegate = gifDataSource
        gifDataSource.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
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

extension CollectionNodeController: CollectionNodeGifDataSourceDelegate {
    func didTap(_ gif: Gif) {
        delegate?.didTap(gif)
    }
    
    func didBeginUpdate(_ context: ASBatchContext?) {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    func didEndUpdate(_ context: ASBatchContext?, with additions: Int, _ connectionStatus: InternetStatus) {
        switch connectionStatus {
        case .noConnection:
            self.activityIndicator.stopAnimating()
            context?.completeBatchFetching(true)
            break
        default:
            self.activityIndicator.stopAnimating()
            self.addRowsIntoTableNode(newCount: additions)
            context?.completeBatchFetching(true)
        }
    }
    
    func addRowsIntoTableNode(newCount newGfys: Int) {
        let indexRange = (feed.numberOfItemsInFeed - newGfys..<feed.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
}

extension CollectionNodeController: MosaicCollectionViewLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAt indexPath: IndexPath) -> CGSize {
        return gifDataSource.feed.gifs[indexPath.row].size()
    }
}

