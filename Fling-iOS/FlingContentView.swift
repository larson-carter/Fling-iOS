//
//  FlingContentView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import SwiftUI

struct FlingContentView: View {
    var ipAddress: String
    @State private var youtubeURL: String = ""
    @State private var isPlaying: Bool = false
    @State private var isSending: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showPreviouslyFlinged: Bool = false  // State to control navigation
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Make this a constant
    
    
    var body: some View {
        NavigationView {
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
                        if isPlaying {
                            pauseVideo()
                        } else {
                            playVideo()
                        }
                    }) {
                        Text(isPlaying ? "Pause" : "Play")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Skip") {
                        skipVideo()
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Button that triggers navigation
                Button("Previously Flinged Content") {
                    showPreviouslyFlinged = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                // Hidden NavigationLink
                NavigationLink(destination: PreviouslyFlingedContentView(ipAddress: ipAddress), isActive: $showPreviouslyFlinged) {
                    EmptyView()
                }
                
                
                Spacer()
            }
            .navigationTitle("Fling Content")
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Unsupported URL"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onReceive(timer) { _ in
                checkIfPlaying()
            }
            
        }
    }
    
    func checkIfPlaying() {
        guard let url = URL(string: "http://\(ipAddress)/api/fling/isPlaying") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to check play status: \(String(describing: error))")
                return
            }
            
            do {
                let status = try JSONDecoder().decode(PlaybackStatus.self, from: data)
                DispatchQueue.main.async {
                    self.isPlaying = status.isPlaying
                }
            } catch {
                print("Failed to decode response: \(error)")
            }
        }.resume()
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
                    alertMessage = "Failed to send URL: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                        case 200:
                            youtubeURL = "" // Clear the text box
                            isPlaying = true // Assume video starts playing
                        case 400:
                            alertMessage = "This app currently only supports YouTube links."
                            showAlert = true
                        default:
                            print("Failed with status code: \(httpResponse.statusCode)")
                            alertMessage = "Failed with status code: \(httpResponse.statusCode)"
                            showAlert = true
                    }
                }
            }
        }.resume()
    }
    
    func pauseVideo() {
        sendPlaybackControl(command: "pause")
    }
    
    func playVideo() {
        sendPlaybackControl(command: "play")
    }
    
    func skipVideo() {
        sendPlaybackControl(command: "skip")
    }
    
    func sendPlaybackControl(command: String) {
        guard let url = URL(string: "http://\(ipAddress)/api/fling/\(command)") else {
            print("Invalid URL for \(command)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("\(command.capitalized) request failed: \(error)")
                    alertMessage = "\(command.capitalized) request failed: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("\(command.capitalized) successfully")
                } else {
                    print("Failed to \(command) with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                    alertMessage = "Failed to \(command) with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    showAlert = true
                }
            }
        }.resume()
    }
}
