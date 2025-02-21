//
//  GKTurnBasedExchangeStatus+helper.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/13/25.
//

import GameKit

public extension GKTurnBasedExchange {
  var statusString : String {
    switch self.status {
    case .active:
      return "active"
    case .canceled:
      return "cancelled"
    case .complete:
      return "complete"
    case .resolved:
      return "resolved"
    case .unknown:
      return "unknown GKTBE"
    @unknown default:
      return "unknown GKTBE"
    }
  }
}

public extension GKTurnBasedExchange {
  // Function to format the date
  func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yy 'at' HH:mm"
    return dateFormatter.string(from: date)
  }

  func dump() {
    print("Exchange: \(self.exchangeID). Status \(self.statusString)")
    for recipient : GKTurnBasedParticipant in self.recipients  {
      print("\t\(recipient.player?.alias ?? "AUTOMATCH") - \(recipient.state)")
    }
    if let replies = self.replies {
      print("\t\(replies.count) replies")
      for reply in replies {
        print("\t\t\(reply.message ?? "NO MESSAGE")")
      }
    }
    print("\tLast updated \(formatDate(self.sendDate)).")
  }
}

