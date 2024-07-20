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
        self.serviceBrowser?.searchForServices(ofType: "_fling._tcp.", inDomain: "local.")
    }

    func stopBrowsing() {
        self.serviceBrowser?.stop()
    }

    // NetServiceBrowserDelegate methods
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if !services.contains(where: { $0.name == service.name && $0.type == service.type }) {
            services.append(service)
            service.delegate = self
            service.resolve(withTimeout: 10)
        }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if let index = services.firstIndex(where: { $0.name == service.name && $0.type == service.type }) {
            services.remove(at: index)
        }
    }

    // NetServiceDelegate methods
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Resolved \(sender.name): \(sender.hostName ?? "unknown host")")
    }

    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve \(sender.name): \(errorDict)")
    }
}
