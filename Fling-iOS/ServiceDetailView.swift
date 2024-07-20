//
//  ServiceDetailView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import SwiftUI

struct ServiceDetailView: View {
    var service: NetService
    @State private var isFlingable: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        VStack {
            Text("Service: \(service.name)")
            if let ip = resolveIPAddress(service: service) {
                Text("IP Address: \(ip)")
                if isLoading {
                    ProgressView()
                } else {
                    if isFlingable {
                        NavigationLink(destination: FlingContentView()) {
                            Text("Fling Content")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    } else {
                        Text("This service is not flingable.")
                    }
                }
            } else {
                Text("IP Address: Unavailable")
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Service Details")
        .onAppear {
            checkFlingableStatus()
        }
    }

    func resolveIPAddress(service: NetService) -> String? {
        guard let addresses = service.addresses, let address = addresses.first else {
            return nil
        }

        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        address.withUnsafeBytes { ptr in
            let sockaddrPtr = ptr.bindMemory(to: sockaddr.self)
            guard let sockaddr = sockaddrPtr.baseAddress else { return }
            getnameinfo(sockaddr, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
        }
        return String(cString: hostname)
    }

    func checkFlingableStatus() {
        guard let ip = resolveIPAddress(service: service) else {
            return
        }

        let urlString = "http://\(ip)/flingable"
        guard let url = URL(string: urlString) else {
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    isFlingable = false
                    return
                }
                isFlingable = true
            }
        }.resume()
    }
}



//
//#Preview {
//    ServiceDetailView()
//}
