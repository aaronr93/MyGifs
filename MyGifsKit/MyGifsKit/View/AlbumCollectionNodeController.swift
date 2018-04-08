//
//  AlbumCollectionNodeController.swift
//  MyAlbumsKit
//
//  Created by Aaron Rosenberger on 2/24/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

public protocol CollectionDelegate: class {
    func didTap(_ item: SendableItem, _ action: TapAction)
}

public class AlbumCollectionNodeController: ASViewController<ASCollectionNode> {
    
    var loadingScreensForBatching: CGFloat {
        didSet { node.leadingScreensForBatching = loadingScreensForBatching }
    }
    
    private let layout: UICollectionViewLayout
    private var feed: AlbumsFeed?
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    private var albumDataSource: AlbumCollectionNodeDataSource!
    
    public var viewTitle: String? {
        get { return navigationItem.title }
        set { navigationItem.title = newValue }
    }
    
    weak public var delegate: CollectionDelegate?
    
    init() {
        layout = UICollectionViewFlowLayout()
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        loadingScreensForBatching = 2.5
        
        super.init(node: collectionNode)
        node.allowsSelection = false
    }
    
    public convenience init(identifier: String, sourceType: FeedModelType) {
        self.init()
        switch sourceType {
        case .GfycatUserAlbums:
            break
        case .ImgurUserAlbums:
            feed = ImgurAccountAlbums(username: identifier)
        default:
            return
        }
        guard let feed = feed else { return }
        albumDataSource = AlbumCollectionNodeDataSource(newFeed: feed)
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
    func didTap(_ item: SendableItem, _ action: TapAction) {
        delegate?.didTap(item, action)
    }
    
    func didBeginUpdate(_ context: ASBatchContext?) {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    func didEndUpdate(_ context: ASBatchContext?, with additions: Int, _ connectionStatus: InternetStatus) {
        DispatchQueue.main.async {
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
    }
    
    func addRowsIntoTableNode(newCount newItems: Int) {
        guard let feed = feed else { return }
        let indexRange = (feed.numberOfItemsInFeed - newItems..<feed.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
}
