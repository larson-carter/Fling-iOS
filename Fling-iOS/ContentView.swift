//
//  ContentView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()

    var body: some View {
        NavigationView {
            List(networkManager.services, id: \.self) { service in
                NavigationLink(destination: ServiceDetailView(service: service)) {
                    Text(service.name)
                }
            }
            .navigationTitle("Available Services")
            .onAppear {
                networkManager.startBrowsing()
            }
            .onDisappear {
                networkManager.stopBrowsing()
            }
        }
    }
}

#Preview {
    ContentView()
}
