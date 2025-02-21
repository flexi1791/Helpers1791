//
//  GKTurnBasedMatch+Helpers.swift
//  Helpers1791
//
//  Created by Felix Andrew Work on 2/21/25.
//
import SwiftUI
import GameKit

public extension GKTurnBasedMatch {
  
  var nextParticipant: GKTurnBasedParticipant? {
    guard let currentParticipantIndex = self.participants.firstIndex(of: self.currentParticipant!) else {
      return nil
    }
    let nextParticipantIndex = (currentParticipantIndex + 1) % self.participants.count
    return self.participants[nextParticipantIndex]
  }
  
  func endTurn(data: Data, completion: @escaping (Error?) -> Void) {
    if let nextParticipant = nextParticipant {
      self.endTurn(withNextParticipants: [nextParticipant],
                   turnTimeout: 60, // GKTurnTimeoutDefault,
                   match: data) { error in
        completion(error)
      }
      completion(nil)
    }
  }
}
