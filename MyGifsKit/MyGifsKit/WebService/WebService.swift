//
//  WebService.swift
//  MyGifs
//
//  Modified by Aaron Rosenberger (https://github.com/aaronr93)
//  Created by Calum Harris on 06/01/2017.
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

final internal class WebService {
    let session: URLSession
    
    init() {
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    func getModel<A: Decodable>(withURL: URL) -> Resource<A> {
        let parse = Resource<A>(url: withURL, parseJSON: { (data: Data, eTag: String?) in
            guard let feed = try? JSONDecoder().decode(A.self, from: data) else {
                return .failure(.errorParsingJSON)
            }
            return .success(feed: feed, eTag: eTag)
        })
        
        return parse
    }
    
    func getHeaders<A: ResponseHeaders>(from data: Data, with type: A.Type) -> A? {
        if let headers = try? JSONDecoder().decode(A.self, from: data) {
            return headers
        }
        return nil
    }
    
    func foo(completion: @escaping (Data?, NetworkingErrors?) -> ()) {
        let request = URLRequest(url: URL(string: "foo")!)
        session.dataTask(with: request) { data, response, error in
            // Check for errors in responses.
            guard error == nil else {
                completion(nil, .returnedError(error!))
                return
            }
            completion(data, nil)
        }.resume()
    }
    
    func load<A: Decodable>(resource: Resource<A>, withHeaders addHeaders: ((URL) -> URLRequest)? = nil, completion: @escaping (Result<A>) -> ()) {
        let request = addHeaders != nil ? addHeaders!(resource.url) : URLRequest(url: resource.url)
        session.dataTask(with: request) { data, response, error in
            // Check for errors in responses.
            let result = self.checkForNetworkErrors(data, response, error)
            switch result {
            case .success(let response):
                completion(resource.parse(response.feed, response.eTag))
            case .failure(let error):
                completion(.failure(error))
            }
        }.resume()
    }
    
}

extension WebService {
    fileprivate func checkForNetworkErrors(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Data> {
        // Check for errors in responses.
        if let error = error {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && (nsError.code == NSURLErrorNotConnectedToInternet || nsError.code == NSURLErrorTimedOut) {
                return .failure(.noInternetConnection)
            } else {
                return .failure(.returnedError(error))
            }
        }
        
        var eTag = ""
        if let response = response as? HTTPURLResponse {
            if let headersData = try? JSONSerialization.data(withJSONObject: response.allHeaderFields) {
                if let headers = try? JSONDecoder().decode(ImgurResponseHeaders.self, from: headersData) {
                    eTag = headers.Etag ?? ""
                }
            }
            
            if (response.statusCode <= 200 && response.statusCode >= 299) {
                return .failure((.invalidStatusCode(response.statusCode)))
            }
        }
        
        guard let data = data else { return .failure(.dataReturnedNil) }
        
        return .success(feed: data, eTag: eTag)
    }
}

struct Resource<A> {
    let url: URL
    let parse: (Data, String?) -> Result<A>
}
extension Resource {
    init(url: URL, parseJSON: @escaping (Data, String?) -> Result<A>) {
        self.url = url
        self.parse = { (data, eTag) in return parseJSON(data, eTag) }
    }
}

enum Result<T> {
    case success(feed: T, eTag: String?)
    case failure(NetworkingErrors)
}

enum InternetStatus {
    case connected
    case noConnection
    case unnecessary
}

enum NetworkingErrors: Error {
    case errorParsingJSON
    case noInternetConnection
    case dataReturnedNil
    case returnedError(Error)
    case invalidStatusCode(Int)
    case customError(String)
}

enum HTTPStatusCode: Int, Decodable {
    // 100 Informational
    case Continue = 100
    case SwitchingProtocols
    case Processing
    // 200 Success
    case OK = 200
    case Created
    case Accepted
    case NonAuthoritativeInformation
    case NoContent
    case ResetContent
    case PartialContent
    case MultiStatus
    case AlreadyReported
    case IMUsed = 226
    // 300 Redirection
    case MultipleChoices = 300
    case MovedPermanently
    case Found
    case SeeOther
    case NotModified
    case UseProxy
    case SwitchProxy
    case TemporaryRedirect
    case PermanentRedirect
    // 400 Client Error
    case BadRequest = 400
    case Unauthorized
    case PaymentRequired
    case Forbidden
    case NotFound
    case MethodNotAllowed
    case NotAcceptable
    case ProxyAuthenticationRequired
    case RequestTimeout
    case Conflict
    case Gone
    case LengthRequired
    case PreconditionFailed
    case PayloadTooLarge
    case URITooLong
    case UnsupportedMediaType
    case RangeNotSatisfiable
    case ExpectationFailed
    case ImATeapot
    case MisdirectedRequest = 421
    case UnprocessableEntity
    case Locked
    case FailedDependency
    case UpgradeRequired = 426
    case PreconditionRequired = 428
    case TooManyRequests
    case RequestHeaderFieldsTooLarge = 431
    case UnavailableForLegalReasons = 451
    // 500 Server Error
    case InternalServerError = 500
    case NotImplemented
    case BadGateway
    case ServiceUnavailable
    case GatewayTimeout
    case HTTPVersionNotSupported
    case VariantAlsoNegotiates
    case InsufficientStorage
    case LoopDetected
    case NotExtended = 510
    case NetworkAuthenticationRequired
}
