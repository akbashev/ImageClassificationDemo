//
//  ContentView.swift
//  Shared
//
//  Created by Jaleel Akbashev on 08.02.21.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store = Store(initialState: SearchState(),
                      reducer: searchReducer,
                      environment: SearchEnvironment(
                        unsplashClient: UnsplashClient.live(baseUrl: URL(string: "https://api.unsplash.com/")!, clientId: ProcessInfo.processInfo.environment["CLIENT_ID"]!),
                        categoriseClient: CategoriseClient.live(),
                        mainQueue: DispatchQueue.main.eraseToAnyScheduler()))
    
    var body: some View {
        SearchView(store: self.store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
