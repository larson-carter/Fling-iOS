//
//  Video.swift
//  Fling-iOS
//
//  Created by Larson Carter on 7/21/24.
//

import Foundation

struct Video: Decodable, Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let thumbnail: String
}
