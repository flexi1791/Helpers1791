//
//  PlayerImageView.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/10/25.
//

import SwiftUI
import GameKit

struct PlayerImageView: View {
  @ObservedObject var playerImage: PlayerImage
  
  init(player: GKPlayer) {
    self.playerImage = player.playerImage
  }
  
  init(player: String)
  {
    self.playerImage = PlayerImage(player:player)
  }
  
  var body: some View {
    Image(uiImage: playerImage.image ?? UIImage())
      .resizable()
      // .frame(width: 50, height: 50)
      .clipShape(Circle())
  }
}

