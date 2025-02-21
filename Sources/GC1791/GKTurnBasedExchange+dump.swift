//
//  GKTurnBasedExchangeStatus+helper.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/13/25.
//

import GameKit

public extension GKTurnBasedExchange {
  /// Computed property to get the status of the GKTurnBasedExchange as a string.
  /// - Returns: A string representation of the status.
  var statusString: String {
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
  
  /// Formats a given date to a string in the format "dd/MM/yy 'at' HH:mm".
  /// - Parameter date: The date to be formatted.
  /// - Returns: A string representation of the formatted date.
  func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yy 'at' HH:mm"
    return dateFormatter.string(from: date)
  }
  
  /// Dumps the details of the GKTurnBasedExchange to the console, including exchange ID, status, recipients, and replies.
  func dump() {
    print("Exchange: \(self.exchangeID). Status \(self.statusString)")
    for recipient in self.recipients {
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
