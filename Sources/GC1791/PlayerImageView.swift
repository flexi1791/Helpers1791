//
//  PlayerImageView.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/10/25.
//

import SwiftUI
import GameKit

/// A SwiftUI view that displays a player's image.
public struct PlayerImageView: View {
  @ObservedObject var playerImage: PlayerImage
  
  /// Initializes a new PlayerImageView with the given GKPlayer.
  /// - Parameter player: The GKPlayer whose image is to be displayed.
  public init(player: GKPlayer) {
    self.playerImage = player.playerImage
  }
  
  /// Initializes a new PlayerImageView with the given player ID.
  /// - Parameter player: The ID of the player whose image is to be displayed.
  public init(player: String) {
    self.playerImage = PlayerImage(playerID: player)
  }
  
  public var body: some View {
    Image(uiImage: playerImage.image ?? UIImage())
      .resizable()
      .clipShape(Circle())
  }
}

