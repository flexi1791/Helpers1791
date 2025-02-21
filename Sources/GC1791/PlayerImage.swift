//
//  PlayerImage.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/10/25.
//

import GameKit
import UIKit
import Combine

/// A class that represents a player's image and handles loading and caching the image.
@MainActor
public class PlayerImage: ObservableObject {
  /// The player's image, published to allow SwiftUI views to react to changes.
  @Published var image: UIImage?
  
  private let player: GKPlayer?
  private let playerID: String?
  private var cancellable: AnyCancellable?
  
  /// Initializes a new PlayerImage with the given player.
  /// - Parameter player: The GKPlayer whose image is to be loaded.
  init(player: GKPlayer) {
    self.player = player
    self.playerID = player.ID
    self.loadImage()
  }
  
  /// Initializes a new PlayerImage with the given player ID.
  /// - Parameter playerID: The ID of the player whose image is to be loaded.
  init(playerID: String) {
    self.player = nil
    self.playerID = playerID
    self.loadImage()
  }
  
  /// Loads the player's image, either from cache or by fetching it.
  private func loadImage() {
    if let playerID = playerID {
      if let cachedImage = PlayerImageCache.shared.loadCachedImage(for: playerID) {
        self.image = cachedImage
        return
      }
    }
    fetchImage()
  }
  
  /// Fetches the player's image and updates the `image` property.
  private func fetchImage() {
    if let player = player {
      cancellable = PlayerImageCache.shared.fetchImage(for: player)
        .sink { [weak self] fetchedImage in
          if let image = fetchedImage {
            self?.image = image
          }
        }
    } else {
      // Use default icon if the player is not available
      image = UIImage(named: "Icon")
      assert(image != nil, "Failed to load default image")
    }
  }
}
