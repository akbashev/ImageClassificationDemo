//
//  UnsplashImage.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import SwiftUI
import Combine

struct UnsplashImage: Decodable, Identifiable, Equatable {
    
    struct URLs: Decodable, Equatable {
        let raw: URL?
        let full: URL?
        let regular: URL?
        let small: URL?
        let thumb: URL?
    }
    
    let id: String
    let created_at: String?
    let width: Int
    let height: Int
    let color: String?
    let blur_hash: String?
    let urls: URLs?
}

struct SearchResponse: Decodable {
    let results: [UnsplashImage]
}
