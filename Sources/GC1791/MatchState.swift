//
//  MatchState.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/10/25.
//

import GameKit
import SwiftUI

/// Enum representing the different states of a match.
public enum MatchState {
  case myTurn
  case theirTurn
  case matchComplete
}

public extension GKTurnBasedMatch {
  /// Computed property to get the game state of the GKTurnBasedMatch.
  /// - Returns: A MatchState value representing the state of the match.
  var gameState: MatchState {
    // If someone quit, then the status is Ended.
    if self.status == .ended {
      return .matchComplete
    }
    
    // It's a currently valid game - we have quit - but the game is not ended yet.
    var someoneEnded = false
    var tiedCount = 0
    
    for participant in self.participants {
      switch participant.matchOutcome {
      case .quit:
        return .matchComplete // someone resigned - the game is over
      case .tied:
        tiedCount += 1
      case .lost, .won:
        someoneEnded = true
      default:
        break
      }
    }
    
    // Sometimes self.status == .open when the game is over.
    if self.status == .open {
      if someoneEnded {
        // print("Confused Ending (someone won/lost)\r\n\(self)")
        return .matchComplete
      }
      
      if tiedCount == 2 {
        // print("Confused Ending (two people tied)\r\n\(self)")
        return .matchComplete
      }
    }
    
    // Our opponent can have resigned - but it's still our turn -
    // This means we can't play another round (participant is invalid errors).
    if self.currentParticipant?.player?.isLocalPlayer ?? false {
      return .myTurn
    }
    
    return .theirTurn
  }
  
  /// Computed property to check if it's our turn.
  /// - Returns: A Boolean value indicating whether it's our turn.
  var ourTurn: Bool {
    return self.currentParticipant?.player?.isLocalPlayer ?? false
  }
}
