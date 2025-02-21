//
//  GKPlayer+Helpers.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/10/25.
//

import GameKit
import Combine

public extension GKPlayer {
  /// Computed property to get the ID of the GKPlayer.
  /// - Returns: The game player ID of the GKPlayer.
  var ID: String {
    return self.gamePlayerID
  }
}

public extension GKTurnBasedParticipant {
  /// Computed property to get the ID of the GKTurnBasedParticipant.
  /// - Returns: The ID of the associated GKPlayer or "Automatch" if the player is nil.
  var ID: String {
    return self.player?.ID ?? "Automatch"
  }
}

/// Extension to add helper properties to GKPlayer
public extension GKPlayer {
  
  @MainActor private static var playerImages = NSMapTable<GKPlayer, PlayerImage>(
    keyOptions: .weakMemory,
    valueOptions: .strongMemory
  )
  
  /// Computed property to get or set the associated PlayerImage for a GKPlayer.
  /// - Returns: The associated PlayerImage object. If it doesn't exist, a new PlayerImage object is created, associated with the GKPlayer, and returned.
  @MainActor
  var playerImage: PlayerImage {
    if let playerImage = GKPlayer.playerImages.object(forKey: self) {
      return playerImage
    } else {
      let playerImage = PlayerImage(player: self)
      GKPlayer.playerImages.setObject(playerImage, forKey: self)
      return playerImage
    }
  }
  
  /// Computed property to check if the GKPlayer is the local player.
  /// - Returns: A Boolean value indicating whether the GKPlayer is the local player.
  var isLocalPlayer: Bool {
    self.ID == GKLocalPlayer.local.ID
  }
}

//
// Authentication extension
//
extension GKLocalPlayer {
  /// Presents the authentication view controller.
  /// - Parameter viewController: The view controller to be presented.
  @MainActor
  private func presentAuthenticationViewController(_ viewController: UIViewController) {
    // Find the key window's root view controller
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
       let rootViewController = keyWindow.rootViewController {
      rootViewController.present(viewController, animated: true, completion: nil)
    }
  }
  
  /// Authenticates the local player with Game Center.
  /// - Parameter completion: A closure that gets called when the authentication process completes.
  ///   If the authentication is successful, the error parameter will be nil. Otherwise, it will contain an error.
  @MainActor
  public func authenticatePlayer(completion: @escaping (Error?) -> Void) {
    self.authenticateHandler = { [weak self] (viewController, error) in
      if let viewController = viewController {
        self?.presentAuthenticationViewController(viewController)
      } else if GKLocalPlayer.local.isAuthenticated {
        print("Authentication succeeded")
        completion(nil)
      } else {
        completion(error)
      }
    }
  }
}
