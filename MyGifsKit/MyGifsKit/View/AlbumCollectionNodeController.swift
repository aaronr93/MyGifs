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
    private let layout = MosaicCollectionViewLayout()
    private let layoutInspector = MosaicCollectionViewLayoutInspector()
    private var feed: AlbumsFeed!
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    
    public var viewTitle: String? {
        get { return navigationItem.title }
        set { navigationItem.title = newValue }
    }
    
    weak public var delegate: CollectionDelegate?
    
    init() {
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: collectionNode)
        node.leadingScreensForBatching = 2.5
        node.allowsSelection = false
        layout.delegate = self
        node.layoutInspector = layoutInspector
    }
    
    public convenience init(identifier: String, sourceType: FeedModelType) {
        self.init()
        switch sourceType {
        case .GfycatUserAlbums:
            break
        case .ImgurUserAlbums:
            feed = ImgurAccountAlbums(username: identifier)
        default:
            fatalError("This feed case has not been implemented: \(sourceType)")
        }
        node.dataSource = self
        node.delegate = self
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

extension AlbumCollectionNodeController: ASCollectionDataSource {
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int { return 1 }
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return feed!.numberOfItemsInFeed
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let album = feed.albums[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let node = AlbumCollectionNode(album: album)
            node.delegate = self
            return node
        }
        return nodeBlock
    }
}

extension AlbumCollectionNodeController: ASCollectionDelegate {
    public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
        feed.updateNewBatch { additions, connectionStatus in
            self.didEndUpdate(context, with: additions, connectionStatus)
        }
    }
    
    public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return feed.shouldBatchFetch()
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

extension AlbumCollectionNodeController: CollectionNodeTapDelegate {
    func didTap(_ item: SendableItem, _ action: TapAction) {
        delegate?.didTap(item, action)
    }
}

extension AlbumCollectionNodeController: MosaicCollectionViewLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, originalItemSizeAt indexPath: IndexPath) -> CGSize {
        guard let albumNode = node.nodeForItem(at: indexPath) as? AlbumCollectionNode else {
            return feed.albums[indexPath.row].coverSize() ?? CGSize(width: 100, height: 100)
        }
        return albumNode.size()
    }
}
