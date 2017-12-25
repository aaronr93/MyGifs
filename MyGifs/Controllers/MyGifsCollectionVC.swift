//
//  MyGifsCollectionVC.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 11/5/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import UIKit
import AVFoundation

fileprivate let gfyReuseIdentifier = "gfy"
fileprivate let loopSafety = 100
fileprivate let kMaxGifs = 20

fileprivate let itemsPerRow: CGFloat = 2.0
fileprivate let sectionInsets = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)

class MyGifsCollectionVC: UICollectionViewController {
    
    let dataController = DataController()
    var i = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.collectionView?.setCollectionViewLayout(MyGifsCollectionFlowLayout(), animated: false)
        self.collectionView?.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: gfyReuseIdentifier)
        DispatchQueue(label: "gfy-data").async { [unowned self] in
            self.getGifsAndUpdateCollection()
        }
    }
}

class MyGifsCollectionFlowLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        self.scrollDirection = .vertical
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

extension MyGifsCollectionVC: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        var height: CGFloat = 108.0
        if let gfy = CacheController.shared.cachedGif(forIndexPath: indexPath) {
            if (gfy.width != nil && gfy.height != nil) {
                let box = CGSize(width: gfy.width!, height: gfy.height!)
                height = getHeight(forContentDimensions: box, withTargetWidth: widthPerItem) ?? height
            }
        }
        return CGSize(width: widthPerItem, height: height)
    }
    
    private func getHeight(forContentDimensions box: CGSize, withTargetWidth targetWidth: CGFloat) -> CGFloat? {
        guard box.height != 0 else {
            return nil
        }
        let ratio = box.width / box.height
        if (ratio > 1) {
            return targetWidth / ratio
        }
        return nil
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension MyGifsCollectionVC {
    // MARK: UICollectionViewDelegate
    
    private func getGifsAndUpdateCollection() {
        let cursorParam = dataController.getCursorParam()
        GfycatApi.getUserGfycats(user: dataController.user, params: cursorParam, success: parseDataAndUpdateCollection)
    }
    
    /// - Note: This method is intended to work on a background thread and update the UI
    /// on the main thread.
    /// - Parameters:
    ///     - data: Raw JSON data to be parsed by `dataController`.
    private func parseDataAndUpdateCollection(data: Data) {
        var indexPathsToUpdate: [IndexPath] = []
        if let fetchedGifs = dataController.parseGifs(from: data) {
            for gfy in fetchedGifs {
                if let player = dataController.createPlayer(from: gfy) {
                    let insertedIndex = CacheController.shared.cache(player: player, forGif: gfy)
                    indexPathsToUpdate.append(IndexPath(row: insertedIndex, section: 0))
                }
            }
        }
        if indexPathsToUpdate.count > 0 {
            DispatchQueue.main.async { [unowned self] in
                self.collectionView?.insertItems(at: indexPathsToUpdate)
            }
        }
        if (!dataController.lastPage && CacheController.shared.playerCache.count < kMaxGifs && i < loopSafety) {
            i += 1
            getGifsAndUpdateCollection()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView.indexPathsForVisibleItems.index(of: indexPath) == nil {
            if let cell = cell as? GifCollectionViewCell {
                if let playerView = cell.thumb {
                    if playerView.player?.rate != 0 {
                        //cell.thumb = nil
                    }
                }
            }
        }
    }
}

extension MyGifsCollectionVC {
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int { return 1 }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CacheController.shared.playerCache.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gfyReuseIdentifier, for: indexPath) as! GifCollectionViewCell
        if let player = CacheController.shared.cachedPlayer(forIndexPath: indexPath) {
            cell.thumb?.player = player
            cell.thumb?.player?.play()
        }
        return cell
    }
}
