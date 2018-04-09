//
//  GifCollectionNodeController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import AsyncDisplayKit

public enum FeedModelType {
    case GfycatUserGifs
    case GfycatAlbumGifs
    case GfycatUserAlbums
    case ImgurUserGifs
    case ImgurAlbumGifs
    case ImgurUserAlbums
}

public class GifCollectionNodeController: ASViewController<ASCollectionNode> {
    weak public var delegate: CollectionDelegate?
    private var feed: GifFeed!
    private let layout = MosaicCollectionViewLayout()
    private let layoutInspector = MosaicCollectionViewLayoutInspector()
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    
    public var viewTitle: String? {
        get { return navigationItem.title }
        set { navigationItem.title = newValue }
    }
    
    init() {
        ASDisableLogging()
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        super.init(node: collectionNode)
        layout.numberOfColumns = 2
        layout.delegate = self
        node.leadingScreensForBatching = 2
        node.layoutInspector = layoutInspector
        node.allowsSelection = false
    }
    
    public convenience init(identifier: String, sourceType: FeedModelType) {
        self.init()
        switch sourceType {
        case .GfycatUserGifs:
            feed = GfyFeed(username: identifier)
        case .GfycatAlbumGifs:
            break
        case .ImgurUserGifs:
            break
        case .ImgurAlbumGifs:
            feed = ImgurGifsFeed(albumId: identifier)
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

extension GifCollectionNodeController: ASCollectionDataSource {
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int { return 1 }
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return feed.numberOfItemsInFeed
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let gif = feed.gifs[indexPath.row]
        let nodeBlock: ASCellNodeBlock = {
            let node = GifCollectionNode(gif: gif)
            node.gifNode.delegate = self
            return node
        }
        return nodeBlock
    }
}

extension GifCollectionNodeController: ASCollectionDelegate {
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
    
    func addRowsIntoTableNode(newCount newGfys: Int) {
        let indexRange = (feed.numberOfItemsInFeed - newGfys..<feed.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
}

extension GifCollectionNodeController: ASVideoNodeDelegate {
    public func didTap(_ videoNode: ASVideoNode) {
        guard let gifNode = videoNode as? ASGifNode else { return }
        guard let viewableUrl = gifNode.viewableUrl else { return }
        guard let gif = feed.getGif(forURL: viewableUrl) else { return }
        delegate?.didTap(gif, .SendTextMessage)
    }
}

extension GifCollectionNodeController: MosaicCollectionViewLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, originalItemSizeAt indexPath: IndexPath) -> CGSize {
        return feed.gifs[indexPath.row].size()
    }
}

