//
//  PlayerImageCache.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/10/25.
//

import GameKit
import UIKit
import Combine

/// A singleton cache for storing and retrieving player images.
@MainActor
class PlayerImageCache {
  static let shared = PlayerImageCache()
  private var cache: [String: UIImage] = [:]
  private let cacheDuration: TimeInterval = 24 * 60 * 60 // 24 hours
  
  private init() {}
  
  /// Loads a cached image for the given player ID.
  /// - Parameter playerID: The ID of the player whose cached image is to be loaded.
  /// - Returns: The cached UIImage if it exists, otherwise nil.
  func loadCachedImage(for playerID: String) -> UIImage? {
    let cacheKey = "playerImage_\(playerID)"
    let cacheDateKey = "playerImageDate_\(playerID)"
    
    if let lastCacheDate = UserDefaults.standard.object(forKey: cacheDateKey) as? Date,
       let cachedImageData = UserDefaults.standard.data(forKey: cacheKey),
       let cachedImage = UIImage(data: cachedImageData),
       Date().timeIntervalSince(lastCacheDate) < cacheDuration {
      return cachedImage
    }
    return nil
  }
  
  /// Fetches the player's image from the network or other source.
  /// - Parameter player: The GKPlayer whose image is to be fetched.
  /// - Returns: A Future that resolves to the fetched UIImage if successful, otherwise nil.
  func fetchImage(for player: GKPlayer) -> Future<UIImage?, Never> {
    return Future { promise in
      // Use the new method for loading players
      player.loadPhoto(for: .small) { image, error in
        if let image = image, error == nil {
          self.cacheImage(image, for: player.ID)
          promise(.success(image))
        } else {
          let image = UIImage(named: "icon")
          promise(.success(image))
        }
      }
    }
  }
  
  /// Caches the player's image.
  /// - Parameters:
  ///   - image: The UIImage to be cached.
  ///   - playerID: The ID of the player whose image is being cached.
  private func cacheImage(_ image: UIImage, for playerID: String) {
    let cacheKey = "playerImage_\(playerID)"
    let cacheDateKey = "playerImageDate_\(playerID)"
    
    if let imageData = image.pngData() {
      UserDefaults.standard.set(imageData, forKey: cacheKey)
      UserDefaults.standard.set(Date(), forKey: cacheDateKey)
    }
  }
}
