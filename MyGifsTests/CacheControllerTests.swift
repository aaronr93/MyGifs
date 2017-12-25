//
//  MyGifsTests.swift
//  MyGifsTests
//
//  Created by Aaron Rosenberger on 12/21/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import XCTest
@testable import MyGifs

class CacheControllerTests: XCTestCase {
    
    var Cache: CacheController! = CacheController()
    var testURL: URL!
    var testURL2: URL!
    var testPlayer: GifPlayer!
    var testPlayer2: GifPlayer!
    var testGif: Gfy!
    var testGif2: Gfy!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testURL = URL(string: "foobar")!
        testURL2 = URL(string: "baz")!
        testPlayer = GifPlayer(url: testURL)
        testPlayer2 = GifPlayer(url: testURL2)
        testGif = Gfy(title: nil, miniUrl: testURL, mobileUrl: nil, thumb360Url: nil, mp4Url: testURL, width: nil, height: nil, tags: nil)
        testGif2 = Gfy(title: nil, miniUrl: nil, mobileUrl: nil, thumb360Url: nil, mp4Url: testURL2, width: nil, height: nil, tags: nil)
        Cache.playerCache.removeAll()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_cachePlayerForGif() {
        let returnValue = Cache.cache(player: testPlayer, forGif: testGif)
        let sizeOfCache = Cache.playerCache.count
        
        XCTAssertTrue(returnValue == 0, "Insert into cache should insert at index 1")
        XCTAssertTrue(sizeOfCache == 1, "Insert into cache failed")
    }
    func testPerformance_cachePlayerForGif() {
        self.measure {
            let _ = Cache.cache(player: testPlayer, forGif: testGif)
        }
    }
    
    func test_cachedPlayerForGif() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let returnValue = Cache.cachedPlayer(forGif: testGif)
        
        XCTAssertEqual(returnValue, testPlayer)
    }
    func testPerformance_cachedPlayerForGif() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        self.measure {
            let _ = Cache.cachedPlayer(forGif: testGif)
        }
    }
    
    func test_cachedPlayerForIndexPath() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let validIndexPath = IndexPath(row: 0, section: 0)
        let invalidRowIndexPath = IndexPath(row: 5, section: 0)
        let validRowIndexPath = IndexPath(row: 0, section: 2)
        
        XCTAssertEqual(Cache.cachedPlayer(forIndexPath: validIndexPath), testPlayer)
        XCTAssertNotEqual(Cache.cachedPlayer(forIndexPath: invalidRowIndexPath), testPlayer)
        XCTAssertEqual(Cache.cachedPlayer(forIndexPath: validRowIndexPath), testPlayer)
    }
    func testPerformance_cachedPlayerForIndexPath() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let validIndexPath = IndexPath(row: 0, section: 0)
        self.measure {
            let _ = Cache.cachedPlayer(forIndexPath: validIndexPath)
        }
    }
    
    func test_cachedGifForIndexPath() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let validIndexPath = IndexPath(row: 0, section: 0)
        let invalidRowIndexPath = IndexPath(row: 5, section: 0)
        let validRowIndexPath = IndexPath(row: 0, section: 2)
        
        XCTAssertEqual(Cache.cachedGif(forIndexPath: validIndexPath), testGif)
        XCTAssertNotEqual(Cache.cachedGif(forIndexPath: invalidRowIndexPath), testGif)
        XCTAssertEqual(Cache.cachedGif(forIndexPath: validRowIndexPath), testGif)
    }
    func testPerformance_cachedGifForIndexPath() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let validIndexPath = IndexPath(row: 0, section: 0)
        self.measure {
            let _ = Cache.cachedGif(forIndexPath: validIndexPath)
        }
    }
    
    func test_indexOfCachedGif() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let targetIndex = Cache.cache(player: testPlayer2, forGif: testGif2)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        
        let index = Cache.indexOf(cached: testGif2)
        
        XCTAssertEqual(targetIndex, index)
        XCTAssertEqual(index, 7)
    }
    func testPerformance_indexOfCachedGif() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer2, forGif: testGif2)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        self.measure {
            let _ = Cache.indexOf(cached: testGif2)
        }
    }
    
    func test_clearCache() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        XCTAssertTrue(Cache.playerCache.count > 0)
        
        Cache.clearCache()
        XCTAssertTrue(Cache.playerCache.count == 0)
    }
    func testPerformance_clearCache() {
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        let _ = Cache.cache(player: testPlayer, forGif: testGif)
        
        self.measure {
            Cache.clearCache()
        }
    }
    
}









