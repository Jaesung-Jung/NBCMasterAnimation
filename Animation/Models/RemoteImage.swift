//
//  RemoteImage.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import Foundation

struct RemoteImage: Decodable, Sendable {
  let id: String
  let size: CGSize
  let likes: Int
  let url: URL

  init(id: String, size: CGSize, likes: Int, url: URL) {
    self.id = id
    self.size = size
    self.likes = likes
    self.url = url
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    let width = try container.decode(Int.self, forKey: .width)
    let height = try container.decode(Int.self, forKey: .height)
    self.size = CGSize(width: width, height: height)
    self.likes = try container.decode(Int.self, forKey: .likes)

    let urlsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .urls)
    self.url = try urlsContainer.decode(URL.self, forKey: .small)
  }
}

// MARK: - RemoteImage.Image

extension RemoteImage: Hashable {
}

// MARK: - RemoteImage.CodingKeys

extension RemoteImage {
  enum CodingKeys: String, CodingKey {
    case id
    case width
    case height
    case likes
    case urls
    case small
  }
}
