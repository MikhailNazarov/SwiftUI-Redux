//
//  ImageService.swift
//  SwiftUI-Redux
//
//  Created by Mikhail Nazarov on 03.12.2020.
//

import Foundation
#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#endif

#if canImport(Cocoa)
import Cocoa
public typealias PlatformImage =  NSImage
#endif
import Combine

public protocol ImageService: WebService {
    func load(imageURL: URL) -> AnyPublisher<PlatformImage, Error>
}
//todo: customize
func configuredURLSession() -> URLSession {
       let configuration = URLSessionConfiguration.default
       configuration.timeoutIntervalForRequest = 60
       configuration.timeoutIntervalForResource = 120
       configuration.waitsForConnectivity = true
       configuration.httpMaximumConnectionsPerHost = 5
       configuration.requestCachePolicy = .reloadIgnoringCacheData
       configuration.urlCache =  .shared
       return URLSession(configuration: configuration)
}

public struct RealImageService: ImageService {
    public static let shared: RealImageService = RealImageService(session: configuredURLSession(), baseURL: "")

    public let session: URLSession
    public let baseURL: String
    public let bgQueue = DispatchQueue(label: "bg_image_queue")
    
    public init(session: URLSession, baseURL: String) {
        self.session = session
        self.baseURL = baseURL
    }
    
    public func load(imageURL: URL) -> AnyPublisher<PlatformImage, Error> {
        return download(rawImageURL: imageURL)
        .subscribe(on: bgQueue)
        .receive(on: DispatchQueue.main)
        .extractUnderlyingError()
        .eraseToAnyPublisher()
    }
    
    private func download(rawImageURL: URL, requests: [URLRequest] = []) -> AnyPublisher<PlatformImage, Error> {
        let urlRequest = URLRequest(url: rawImageURL)
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                guard let image = PlatformImage(data: data)
                    else { throw APIError.imageProcessing(requests + [urlRequest]) }
                return image
            }
            .eraseToAnyPublisher()
    }
    
//    private func removeCachedResponses(error: Error) -> AnyPublisher<UIImage, Error> {
//        if let apiError = error as? APIError,
//            case let .imageProcessing(urlRequests) = apiError,
//            let cache = session.configuration.urlCache {
//            urlRequests.forEach(cache.removeCachedResponse)
//        }
//        return Fail(error: error).eraseToAnyPublisher()
//    }
}

public struct FakeImageService: ImageService{
    
    public init(){
        session = URLSession.shared
        baseURL = ""
        bgQueue = DispatchQueue.main
    }
    public func load(imageURL: URL) -> AnyPublisher<PlatformImage, Error> {
        return Just(PlatformImage())
            
            .mapError{
                _ in NSError()
            }
            .eraseToAnyPublisher()
    }
    
    public var session: URLSession
    
    public var baseURL: String
    
    public var bgQueue: DispatchQueue
    
    
}
