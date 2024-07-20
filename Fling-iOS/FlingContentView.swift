//
//  FlingContentView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import SwiftUI

struct FlingContentView: View {
    var ipAddress: String // The IP address of the service
    @State private var youtubeURL: String = ""
    @State private var isPlaying: Bool = false
    @State private var isSending: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter YouTube URL", text: $youtubeURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            if !youtubeURL.isEmpty {
                Button("Send") {
                    sendYouTubeURL()
                }
                .disabled(isSending)
                .padding()
                .background(isSending ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            HStack(spacing: 40) {
                Button(action: {
                    togglePlayPause()
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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Unsupported URL"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func sendYouTubeURL() {
        let escapedURL = youtubeURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "http://\(ipAddress)/api/fling?url=\(escapedURL)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        isSending = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSending = false
                if let error = error {
                    print("Failed to send URL: \(error)")
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        youtubeURL = "" // Clear the text box
                        isPlaying = true // Set to play
                    case 400:
                        alertMessage = "This app currently only supports YouTube links."
                        showAlert = true
                    default:
                        print("Failed with status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }.resume()
    }

    func togglePlayPause() {
        isPlaying.toggle()
    }
}


//#Preview {
//    FlingContentView()
//}
