//
//  ImgurWebHelper.swift
//  MyGifsKit
//
//  Created by Aaron Rosenberger on 2/27/18.
//  Copyright © 2018 Aaron Rosenberger. All rights reserved.
//

protocol ImgurHeaders {
    var Etag: String? { get set }
}

struct ImgurRequestHeaders: ImgurHeaders, RequestHeaders {
    var Authorization: String?
    var Etag: String?
    
    enum CodingKeys: String, CodingKey {
        case Etag = "If-None-Match"
    }
    
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try? values.encode(Etag, forKey: .Etag)
    }
}

struct ImgurResponseHeaders: ImgurHeaders, ResponseHeaders {
    var Etag: String?
    var XCache: eXCacheResult?
    var XCacheHits: Int?
    var CacheControl: String?
    var XRateLimitClientRemaining: Int?
    var XRateLimitClientLimit: Int?
    var XRateLimitUserRemaining: Int?
    var XRateLimitUserLimit: Int?
    var XRateLimitUserReset: Int?
    var ContentType: eResponseContentType?
    var ContentEncoding: eResponseContentEncoding?
    var ContentLength: Int?
    var ResponseAge: Int?
    var ResponseDate: Date?
}
extension ImgurResponseHeaders {
    enum CodingKeys: String, CodingKey {
        case Etag
        case XCache = "x-cache"
        case XCacheHits = "x-cache-hits"
        case CacheControl = "Cache-Control"
        case XRateLimitClientRemaining = "x-ratelimit-clientremaining"
        case XRateLimitClientLimit = "x-ratelimit-clientlimit"
        case XRateLimitUserRemaining = "x-ratelimit-userremaining"
        case XRateLimitUserLimit = "x-ratelimit-userlimit"
        case XRateLimitUserReset = "x-ratelimit-userreset"
        case ContentType = "Content-Type"
        case ContentEncoding = "Content-Encoding"
        case ContentLength = "Content-Length"
        case ResponseAge = "Age"
        case ResponseDate = "Date"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        Etag = try? values.decode(String.self, forKey: .Etag).dropFirst(3).dropLast(1).lowercased()
        XCache = try? values.decode(eXCacheResult.self, forKey: .XCache)
        if let xCacheHits = try? values.decode(String.self, forKey: .XCacheHits) { XCacheHits = Int(xCacheHits) }
        CacheControl = try? values.decode(String.self, forKey: .CacheControl)
        if let xRateLimitClientRemaining = try? values.decode(String.self, forKey: .XRateLimitClientRemaining) { XRateLimitClientRemaining = Int(xRateLimitClientRemaining) }
        if let xRateLimitClientLimit = try? values.decode(String.self, forKey: .XRateLimitClientLimit) { XRateLimitClientLimit = Int(xRateLimitClientLimit) }
        if let xRateLimitUserRemaining = try? values.decode(String.self, forKey: .XRateLimitUserRemaining) { XRateLimitUserRemaining = Int(xRateLimitUserRemaining) }
        if let xRateLimitUserLimit = try? values.decode(String.self, forKey: .XRateLimitUserLimit) { XRateLimitUserLimit = Int(xRateLimitUserLimit) }
        if let xRateLimitUserReset = try? values.decode(String.self, forKey: .XRateLimitUserReset) { XRateLimitUserReset = Int(xRateLimitUserReset) }
        ContentType = try? values.decode(eResponseContentType.self, forKey: .ContentType)
        ContentEncoding = try? values.decode(eResponseContentEncoding.self, forKey: .ContentEncoding)
        if let contentLength = try? values.decode(String.self, forKey: .ContentLength) { ContentLength = Int(contentLength) }
        if let responseAge = try? values.decode(String.self, forKey: .ResponseAge) { ResponseAge = Int(responseAge) }
        if let responseDate = try? values.decode(String.self, forKey: .ResponseDate) { ResponseDate = responseDate.toDate(dateFormat: "E, d MMM yyyy HH:mm:ss zzz") }
    }
    enum eXCacheResult: String, Decodable {
        case Hit = "HIT"
        case Miss = "MISS"
    }
    enum eResponseContentEncoding: String, Decodable {
        case gzip = "gzip"
    }
}

extension String {
    func toDate(dateFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from: self)!
    }
}
