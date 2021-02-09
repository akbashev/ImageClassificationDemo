//
//  Search.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import Foundation
import ComposableArchitecture
import Combine

struct SearchState: Equatable {
    var isLoading: Bool = false
    var query: String = ""
    var page = 0
    var perPage = 30
    var orientation: Orientation? = nil
    var images: [UnsplashImage] = []
    var imagesToShow: [UnsplashImage] {
        return self.images
            .filter { $0.urls?.regular != nil && $0.urls?.thumb != nil }
            .filter {
                if filter.count > 0 {
                    return self.categorisation[$0.id] == filter
                }
                return true
            }
    }
    var categorisation: [String: String] = [:]
    var filters: [String] = ["Cat", "Dog"]
    var filter: String = ""
    
    public init() {}
}

enum SearchAction: Equatable {
    case loadImages(query: String)
    case imagesResponse(Result<[UnsplashImage], UnsplashClient.Failure>)
    case categorisationResponse(Result<[String:String], CategoriseClient.Failure>)
    case categorise([UnsplashImage])
    case reset
    case apply(filter: String)
}

struct SearchEnvironment {
    
    var unsplashClient: UnsplashClient
    var categoriseClient: CategoriseClient
    var mainQueue: AnySchedulerOf<DispatchQueue>
    
    init(unsplashClient: UnsplashClient,
         categoriseClient: CategoriseClient,
         mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.unsplashClient = unsplashClient
        self.categoriseClient = categoriseClient
        self.mainQueue = mainQueue
    }
}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> {
    state, action, environment in
    switch action {
    case .loadImages(let query):
        if query != state.query {
            state.page = 0
            state.images = []
            state.query = query
        }
        state.isLoading = true
        let page = state.page + 1
        return environment.unsplashClient
            .searchImages(query, page, state.perPage, state.orientation)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(SearchAction.imagesResponse)
    case let .imagesResponse(.success(result)):
        state.isLoading = false
        guard result.count > 0 else { return .none }
        state.images = result
        state.page += 1
        return Just(SearchAction.categorise(result))
            .eraseToEffect()
    case let .imagesResponse(.failure(error)):
        return .none
    case let .categorisationResponse(.success(result)):
        state.categorisation = result
        return .none
    case let .categorisationResponse(.failure(error)):
        return .none
    case .reset:
        state.page = 0
        state.images = []
        state.filter = ""
        return .none
    case .apply(let filter):
        state.filter = filter
        return .none
    case .categorise(let images):
        return environment.categoriseClient
            .categoriseImages(images)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { SearchAction.categorisationResponse($0) }
    }
}
