//
//  GKTurnBasedMatch+dump.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/15/25.
//
import Foundation
import GameKit

extension GKTurnBasedMatch {
  var matchStatus: String {
    switch self.status {
    case .open:
      return "Open"
    case .ended:
      return "Ended"
    case .matching:
      return "Matching"
    case .unknown:
      return "Unknown - match state"
    @unknown default:
      return "Unknown - match state"
    }
  }
}

extension GKTurnBasedMatch {  
  func dumpMatch() {
    print("---- dumpMatch ----")
    print("\(self.matchID) is \(self.matchStatus)")
    for participant in self.participants {
      if let player = participant.player {
        print( "\t\(player.alias):\(participant.state) - \(participant.rowStatus)" )
      } else {
        print( "\tAUTOMATCH\t:\(participant.state) - \(participant.rowStatus)")
      }
    }
    if let exchanges = self.exchanges {
      print("\(exchanges.count) exchanges")
      for exchange in exchanges {
        exchange.dump()
      }
    }
    print("\n-----\n")
  }
}

