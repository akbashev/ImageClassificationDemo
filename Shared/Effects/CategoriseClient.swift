//
//  CategoriseClient.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import ComposableArchitecture
import Foundation

struct CategoriseClient {
    
    public var categoriseImage: (UnsplashImage) -> Effect<(String, String), Failure>
    public var categoriseImages: ([UnsplashImage]) -> Effect<[String:String], Failure>
    
    public struct Failure: Error, Equatable {}
}

extension CategoriseClient {
    static func live() -> CategoriseClient { 
        let categoriseService = CategoriseService()
        return CategoriseClient(categoriseImage: { image in
            return categoriseService
                .categorise(image)
                .mapError { _ in CategoriseClient.Failure() }
                .eraseToEffect()
        }, categoriseImages: { images in
            return categoriseService
                .categorise(images)
                .mapError { _ in CategoriseClient.Failure() }
                .eraseToEffect()
        })
    }
}

private let queue = DispatchQueue(label: "UnsplashClient")
