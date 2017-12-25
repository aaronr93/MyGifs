//
//  CacheController.swift
//  My Gifs
//
//  Created by Aaron Rosenberger on 12/16/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import Foundation
import AVFoundation

private let _singletonInstance = CacheController()

class CacheController {
    
    static var shared: CacheController {
        return _singletonInstance
    }
    
    /// Array of tuples allows association of both a `Gfy` and a
    /// `GifPlayer` to the same `Int` index.
    var playerCache = [(gfy: Gfy, player: GifPlayer)]()
    
    /// - Note: Keep track of the return value in order to have O(1)
    /// access via index later.
    /// - Parameters:
    ///     - player: The `GifPlayer` instance associated with `gfy`
    ///     - gfy: The `Gfy` instance for which a `GifPlayer` is created
    /// - Returns: The index at which the tuple was inserted
    func cache(player: GifPlayer, forGif gfy: Gfy) -> Int {
        playerCache.append((gfy, player))
        return playerCache.count - 1
    }
    
    /// Finds the `GifPlayer` that was created for `gfy`.
    /// - Complexity: `O(N)`
    func cachedPlayer(forGif gfy: Gfy) -> GifPlayer? {
        if let cached = playerCache.first(where: { $0.gfy == gfy }) {
            return cached.player
        }
        return nil
    }
    
    /// - Important: The `section` property of `indexPath` is ignored.
    /// - Complexity: `O(1)`
    /// - Returns: The `GifPlayer` for the specified `indexPath`
    func cachedPlayer(forIndexPath indexPath: IndexPath) -> GifPlayer? {
        if (playerCache.count == 0 ||
            indexPath.row >= playerCache.endIndex ||
            indexPath.row < playerCache.startIndex) {
            return nil
        }
        return playerCache[indexPath.row].player
    }
    
    /// - Important: The `section` property of `indexPath` is ignored.
    /// - Complexity: `O(1)`
    /// - Returns: The `Gfy` for the specified `indexPath`
    func cachedGif(forIndexPath indexPath: IndexPath) -> Gfy? {
        if (playerCache.count == 0 ||
            indexPath.row >= playerCache.endIndex ||
            indexPath.row < playerCache.startIndex) {
            return nil
        }
        return playerCache[indexPath.row].gfy
    }
    
    /// - Returns: The index (or `nil`) of `gfy` in `playerCache`.
    /// - Complexity: `O(N)` where `N` is `playerCache.count`
    func indexOf(cached gfy: Gfy) -> Int? {
        return playerCache.index(where: { $0.gfy == gfy })
    }
    
    func clearCache() { playerCache.removeAll() }
}
