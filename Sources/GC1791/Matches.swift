import GameKit
import SwiftUI

/// A class that manages turn-based matches and handles fetching and organizing matches.
@MainActor
public class Matches: NSObject, ObservableObject {
  /// The shared singleton instance of the Matches class.
  public static let shared = Matches()
  
  /// A dictionary that stores matches categorized by their state.
  @Published public var matches: [MatchState: [GKTurnBasedMatch]] = [
    .myTurn: [],
    .theirTurn: [],
    .matchComplete: []
  ]
  
  /// Fetches the list of turn-based matches from Game Center.
  public func fetchGameList() {
    GKTurnBasedMatch.loadMatches { [weak self] (matches, error) in
      if let error = error {
        print("Error fetching game list: \(error.localizedDescription)")
      } else {
        self?.organizeMatches(matches ?? [])
      }
    }
  }
  
  /// Refreshes the match list by fetching the game list from Game Center.
  public func refresh() {
    DispatchQueue.main.async {
      self.fetchGameList()
    }
  }
  
  /// Organizes matches into different categories based on their state and sorts them by the time since the last turn.
  /// - Parameter matches: An array of GKTurnBasedMatch objects to be organized.
  private func organizeMatches(_ matches: [GKTurnBasedMatch]) {
    var myTurn: [GKTurnBasedMatch] = []
    var theirTurn: [GKTurnBasedMatch] = []
    var completed: [GKTurnBasedMatch] = []
    
    for match in matches {
      switch match.gameState {
      case .myTurn:
        myTurn.append(match)
      case .theirTurn:
        theirTurn.append(match)
      case .matchComplete:
        completed.append(match)
      }
    }
    
    // Sort matches by time since last turn
    myTurn.sort { $0.timeSinceLastTurn() < $1.timeSinceLastTurn() }
    theirTurn.sort { $0.timeSinceLastTurn() < $1.timeSinceLastTurn() }
    completed.sort { $0.timeSinceLastTurn() < $1.timeSinceLastTurn() }
    
    DispatchQueue.main.async {
      self.matches[.myTurn] = myTurn
      self.matches[.theirTurn] = theirTurn
      self.matches[.matchComplete] = completed
    }
  }
}

extension TimeInterval {
  func formattedString() -> String {
    let intervalSeconds = Int(self)
    let minutes = (intervalSeconds / 60) % 60
    let hours = intervalSeconds / 3600
    
    if intervalSeconds == 0 {
      return "now"
    }
    
    var delay: String
    if hours == 0 {
      if minutes < 1 {
        delay = "now"
      } else if minutes == 1 {
        delay = "about 1 minute ago"
      } else {
        delay = "\(minutes) minutes ago"
      }
    } else {
      if hours < 24 {
        if hours == 1 {
          delay = "\(hours) hour ago"
        } else {
          delay = "\(hours) hours ago"
        }
      } else {
        if hours >= 24 * 14 {
          delay = "more than two weeks"
        } else {
          let days = hours / 24
          if days == 1 {
            delay = "about a day ago"
          } else {
            delay = "more than \(days) days ago"
          }
        }
      }
    }
    
    return delay
  }
}
