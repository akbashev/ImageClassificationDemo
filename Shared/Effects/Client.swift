//
//  Client.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import ComposableArchitecture
import Foundation

struct UnsplashClient {
        
    public var searchImages: (String, Int, Int, Orientation?) -> Effect<[UnsplashImage], Failure>
    
    public struct Failure: Error, Equatable {}
}

extension UnsplashClient {
    static func live(baseUrl: URL, clientId: String) -> UnsplashClient {
        let api = API(baseUrl: baseUrl, clientId: clientId)
        return UnsplashClient(searchImages: { query, page, perPage, orientation in
            return api.searchImages(matching: query, at: page, perPage: perPage, orientation: orientation)
                .process()
                .map { $0.results }
                .mapError { _ in UnsplashClient.Failure() }
                .eraseToEffect()
        })
    }
}

private let queue = DispatchQueue(label: "UnsplashClient")
