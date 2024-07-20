//
//  NetworkManager.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/20/24.
//

import Foundation
import Combine

class NetworkManager: NSObject, ObservableObject, NetServiceBrowserDelegate, NetServiceDelegate {
    @Published var services = [NetService]()

    private var serviceBrowser: NetServiceBrowser?

    override init() {
        super.init()
        self.serviceBrowser = NetServiceBrowser()
        self.serviceBrowser?.delegate = self
    }

    func startBrowsing() {
        self.serviceBrowser?.searchForServices(ofType: "_p._tcp.", inDomain: "local.")
    }

    func stopBrowsing() {
        self.serviceBrowser?.stop()
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if !services.contains(where: { $0.name == service.name && $0.type == service.type }) {
            services.append(service)
            service.delegate = self
            service.resolve(withTimeout: 10)
        }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        removeService(service)
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        if resolveIPAddress(service: sender) == nil {
            removeService(sender)
        } else {
            print("Resolved \(sender.name): \(sender.hostName ?? "unknown host")")
        }
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve \(sender.name): \(errorDict)")
        removeService(sender)
    }

    private func removeService(_ service: NetService) {
        if let index = services.firstIndex(where: { $0.name == service.name && $0.type == service.type }) {
            DispatchQueue.main.async {
                self.services.remove(at: index)
            }
        }
    }

    private func resolveIPAddress(service: NetService) -> String? {
        guard let addresses = service.addresses, let address = addresses.first else {
            return nil
        }

        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        address.withUnsafeBytes { ptr in
            let sockaddrPtr = ptr.bindMemory(to: sockaddr.self)
            guard let sockaddr = sockaddrPtr.baseAddress else { return nil }
            getnameinfo(sockaddr, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
        }
        return String(cString: hostname)
    }
}
