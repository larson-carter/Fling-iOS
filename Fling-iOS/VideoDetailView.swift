//
//  VideoDetailView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/21/24.
//

import SwiftUI

struct VideoDetailView: View {
    var video: Video

    var body: some View {
        VStack {
            Text(video.title)
                .font(.title)
            Link("Watch on YouTube", destination: URL(string: video.url)!)
            AsyncImage(url: URL(string: video.thumbnail)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 300, height: 200)
            .cornerRadius(8)
        }
        
        .padding()
        .navigationTitle("Video Details")
        .navigationBarBackButtonHidden(true)
    }
}


//#Preview {
//    VideoDetailView()
//}
