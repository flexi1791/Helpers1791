import GameKit
import SwiftUI

/// A class that manages turn-based matches and handles fetching and organizing matches.
@MainActor
public class Matches: NSObject, ObservableObject {
  /// The shared singleton instance of the Matches class.
  public static let shared = Matches()
  
  /// A dictionary that stores matches categorized by their state.
  @Published var matches: [MatchState: [GKTurnBasedMatch]] = [
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
  
  /// Organizes matches into different categories based on their state.
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
    
    DispatchQueue.main.async {
      self.matches[.myTurn] = myTurn
      self.matches[.theirTurn] = theirTurn
      self.matches[.matchComplete] = completed
    }
  }
}
