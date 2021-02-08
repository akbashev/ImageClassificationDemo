//
//  API.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import Foundation
import Combine

struct API {
    let baseUrl: URL
    let clientId: String
    
    init(baseUrl: URL, clientId: String) {
        self.baseUrl = baseUrl
        self.clientId = clientId
    }
    
    
    func url(with path: String) -> URL {
        return URL(string: path, relativeTo: self.baseUrl)!
    }
}

// AUTH
extension API {
    func searchImages(matching query: String, at page: Int = 1, perPage: Int = 30, orientation: Orientation? = nil) -> Endpoint<SearchResponse> {
        var queryItems = [
            "query": query,
            "page": "\(page)",
            "per_page": "\(perPage)",
            "client_id": self.clientId
        ]
        
        if let orientation = orientation?.rawValue {
            queryItems["orientation"] = orientation
        }


        return Endpoint(json: .get,
                        url: self.url(with: "search/photos"),
                        query: queryItems)
    }
    
}

// MARK: - Private helpers

private let iso8601JsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
}()
