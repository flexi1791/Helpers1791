//
//  GKTurnBasedParticipant+Helpers.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/12/25.
//
import GameKit

public extension GKTurnBasedParticipant {
  var state: String {
    get {
      switch self.status {
      case .declined:
        return "declined"
      case .active:
        return "active"
      case .done:
        return "done"
      case .invited:
        return "invited"
      case .matching:
        return "matching"
      case .unknown:
        return "unknown status"
      @unknown default:
        return "oops! GKTBP.status"
      }
    }
  }
}

public extension GKTurnBasedParticipant {
  var rowStatus: String {
    switch self.status {
    case .invited:
      return "Invited"
      
    case .declined:
      return "declined your invitation"
      
    case .matching:
      return "waiting for them to accept the invitation"
      
    case .active:
      return "chatting!"
      
    case .done:
      return "Done"
      
    case .unknown:
      return "Unknown"
      
    default:
      return "Unknown"
    }
  }
}

