//
//  SearchView.swift
//  ImageClassificationDemo (iOS)
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import SwiftUI
import FetchImage
import ComposableArchitecture

struct SearchView: View {
    
    @State private var query: String = ""
    let store: Store<SearchState, SearchAction>
    
    public init(store: Store<SearchState, SearchAction>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            SearchContentView(query: $query,
                              filter: viewStore.state.filter,
                              isLoading: viewStore.state.isLoading,
                              images: viewStore.state.imagesToShow,
                              filters: viewStore.state.filters,
                              onCommit: { viewStore.send(SearchAction.loadImages(query: self.query)) },
                              reset: { viewStore.send(SearchAction.reset) },
                              onFilterApplied: { viewStore.send(SearchAction.apply(filter: $0)) })
        }
    }
}

struct SearchContentView: View {
    
    @Binding var query: String
    
    let filter: String
    let isLoading: Bool
    let images: [UnsplashImage]
    let filters: [String]
    let onCommit: () -> Void
    let reset: () -> Void
    let onFilterApplied: (String) -> Void
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    TextField("Type something", text: $query, onCommit: onCommit)
                    Button("Reset", action: {
                        self.query = ""
                        reset()
                    })
                }
                HStack(alignment: .bottom) {
                    Spacer()
                    Text("Filter by:")
                    Menu {
                        ForEach(filters, id: \.self) { filter in
                            Button(filter, action: {
                                self.onFilterApplied(filter)
                            })
                        }
                    } label: {
                        Text(filter)
                        Image(systemName: "hare")
                    }
                }
            }.padding()
            List {
                ForEach(images) { repo -> ImageRow in
                    let image =  FetchImage(regularUrl: repo.urls!.regular!,
                                            lowDataUrl: repo.urls!.thumb!)
                    image.fetch()
                    return ImageRow(image: image,
                                    color: Color(hex: repo.color))
                }
                if images.count > 0 {
                    Button("Load more", action: onCommit)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                if isLoading {
                    Text("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct ImageRow: View {
    @ObservedObject var image: FetchImage
    let color: Color?
    
    var body: some View {
        image.view?
            .resizable()
            .aspectRatio(contentMode: .fit)
            // (Optional) Cancel and restart requests during scrolling
            .onAppear(perform: image.fetch)
            .onDisappear(perform: image.cancel)
    }
}
