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
    
    var numberOfColumns: Int {
        didSet { layout.numberOfColumns = numberOfColumns }
    }
    
    var loadingScreensForBatching: CGFloat {
        didSet { node.leadingScreensForBatching = loadingScreensForBatching }
    }
    
    private var feed: GifFeed?
    
    private let layout: MosaicCollectionViewLayout
    private let layoutInspector: MosaicCollectionViewLayoutInspector
    
    private var activityIndicator: UIActivityIndicatorView!
    private let collectionNode: ASCollectionNode
    private var gifDataSource: GifCollectionNodeDataSource!
    
    weak public var delegate: CollectionDelegate?
    
    init() {
        ASDisableLogging()
        
        layout = MosaicCollectionViewLayout()
        layoutInspector = MosaicCollectionViewLayoutInspector()
        collectionNode = ASCollectionNode(collectionViewLayout: layout)
        numberOfColumns = 1
        loadingScreensForBatching = 2
        
        super.init(node: collectionNode)
        layout.delegate = self
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
            return
        }
        gifDataSource = GifCollectionNodeDataSource(newFeed: feed!)
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

extension GifCollectionNodeController: CollectionNodeDataSourceDelegate {
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
    
    func addRowsIntoTableNode(newCount newGfys: Int) {
        let indexRange = (feed!.numberOfItemsInFeed - newGfys..<feed!.numberOfItemsInFeed)
        let indexPaths = indexRange.map { IndexPath(row: $0, section: 0) }
        node.insertItems(at: indexPaths)
    }
}

extension GifCollectionNodeController: MosaicCollectionViewLayoutDelegate {
    internal func collectionView(_ collectionView: UICollectionView, layout: MosaicCollectionViewLayout, originalItemSizeAt indexPath: IndexPath) -> CGSize {
        return gifDataSource.feed.gifs[indexPath.row].size()
    }
}

