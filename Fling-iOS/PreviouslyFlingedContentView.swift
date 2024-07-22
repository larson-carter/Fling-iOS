//
//  PreviouslyFlingedContentView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/21/24.
//

import SwiftUI

struct PreviouslyFlingedContentView: View {
    var ipAddress: String
    @State private var videos: [Video] = []

    var body: some View {
        
        NavigationView {
            List(videos) { video in
                NavigationLink(destination: VideoDetailView(video: video)) {
                    VStack(alignment: .leading) {
                        Text(video.title)
                            .font(.headline)
                        Text(video.url)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Previous Content")
            .onAppear {
                loadVideos()
            }
            
        }

        //.navigationBarTitle("Previously Flinged Videos", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
    }

    func loadVideos() {
        guard let url = URL(string: "http://\(ipAddress)/api/fling/urls") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error during data fetching: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let videoList = try JSONDecoder().decode(VideoList.self, from: data)
                DispatchQueue.main.async {
                    self.videos = videoList.videos
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
}

//#Preview {
//    PreviouslyFlingedContentView()
//}
