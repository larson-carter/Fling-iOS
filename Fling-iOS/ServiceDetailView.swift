//
//  ServiceDetailView.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import SwiftUI

struct ServiceDetailView: View {
    var service: NetService

    var body: some View {
        VStack {
            Text("Service: \(service.name)")
            Text("IP Address: \(resolveIPAddress(service: service) ?? "Unavailable")")
            Spacer()
        }
        .padding()
        .navigationTitle("Service Details")
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
}

//
//#Preview {
//    ServiceDetailView()
//}
