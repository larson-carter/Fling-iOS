//
//  FlingContentView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import SwiftUI

struct FlingContentView: View {
    @State private var youtubeURL: String = ""
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter YouTube URL", text: $youtubeURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack(spacing: 40) {
                Button(action: {
                    isPlaying.toggle()
                }) {
                    Text(isPlaying ? "Pause" : "Play")
                }
                
                Button(action: {
                    // Define skip behavior here
                    print("Skip pressed")
                }) {
                    Text("Skip")
                }
            }
            Spacer()
        }
        .navigationTitle("Fling Content")
        .padding()
    }
}


#Preview {
    FlingContentView()
}
