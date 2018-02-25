//
//  AlbumCollectionNodeController.swift
//  MyAlbumsKit
//
//  Created by Aaron Rosenberger on 2/24/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

public class AlbumCollectionNodeController: ASViewController<ASCollectionNode> {
    
    var loadingScreensForBatching: CGFloat {
        didSet { node.leadingScreensForBatching = loadingScreensForBatching }
    }
    
    private var feed: AlbumsFeed
    private let layout: UICollectionViewLayout
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    private var albumDataSource: AlbumCollectionNodeDataSource
    
    weak public var delegate: CollectionDelegate?
    
    public init() {
        layout = UICollectionViewFlowLayout()
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        loadingScreensForBatching = 2.5
        
        feed = ImgurAccountAlbums(username: "aaronr93")
        albumDataSource = AlbumCollectionNodeDataSource(newFeed: feed)
        
        super.init(node: collectionNode)
        
        node.allowsSelection = false
        node.dataSource = albumDataSource
        node.delegate = albumDataSource
        albumDataSource.delegate = self
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

extension AlbumCollectionNodeController: CollectionNodeDataSourceDelegate {
    func didTap(_ item: SendableItem) {
        delegate?.didTap(item)
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
    
    func addRowsIntoTableNode(newCount newItems: Int) {
        let indexRange = (feed.numberOfItemsInFeed - newItems..<feed.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
}
