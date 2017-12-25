//
//  DataControllerTests.swift
//  MyGifsTests
//
//  Created by Aaron Rosenberger on 12/23/17.
//  Copyright © 2017 Aaron Rosenberger. All rights reserved.
//

import XCTest
@testable import MyGifs

class DataControllerTests: XCTestCase {
    
    var dataController = DataController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        dataController.cursor = ""
        dataController.lastPage = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func test_parseGifsFromData() {
//        var data: Data?
//        if let file = Bundle.main.path(forResource: "GfycatRawData", ofType: "json") {
//            do {
//                data = try String(contentsOfFile: file, encoding: .utf8).data(using: .utf8)
//            } catch {
//                XCTFail("Failed to read sample JSON file")
//            }
//        } else {
//            XCTFail("Failed to find document file directory")
//        }
//        if let data = data {
//            let gfystest = dataController.parseGifs(from: data)
//            if let gfys = dataController.parseGifs(from: data) {
//                XCTAssertTrue(true)
//            } else {
//                XCTFail("Failed to unwrap parsed gfys")
//            }
//        } else {
//            XCTFail("Failed to unwrap optional `data`")
//        }
//    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
