@preconcurrency import GameKit
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
  
  // Mark this function as @preconcurrency to suppress Sendable warnings
  @preconcurrency
  func fetchGameList() async {
    // Always handle GameKit matches on the main thread to avoid Sendable/threading issues
    let matches = try? await GKTurnBasedMatch.loadMatches()
    
    self.organizeMatches(matches)
  }

  // MARK: - Game Center Integration
  public func refreshGames() async {
    await fetchGameList()
  }

  // Also mark organizeMatches as @preconcurrency for clarity
  @preconcurrency @MainActor
  func organizeMatches(_ matches: [GKTurnBasedMatch]?) {
    var playingGames: [GKTurnBasedMatch] = []
    var waitingGames: [GKTurnBasedMatch] = []
    var reviewGames: [GKTurnBasedMatch] = []
    
    if let matches = matches {
      
      let matchIDs = matches.map { (match: GKTurnBasedMatch) in
        match.matchID as NSString
      }
      
      // We have a local game state which stores thumbnails and things
      // once a game is no longer needed, we need to delete it to save space.
      // LocalGameStateStore.singleton().keepTheseMatches(matchIDs as [String])
      
      for match in matches {
        switch match.gameState {
        case .myTurn:
          playingGames.append(match)
        case .theirTurn:
          waitingGames.append(match)
        case .matchComplete:
          reviewGames.append(match)
        @unknown default:
          print("zzzz - Don't know what to do with this!")
        }
      }
    }
    
    // Sort matches by time since last turn
    withAnimation {
      updateGames(currentGames: &self.matches[.myTurn, default: []], newGames: playingGames)
      updateGames(currentGames: &self.matches[.theirTurn, default: []], newGames: waitingGames)
      updateGames(currentGames: &self.matches[.matchComplete, default: []], newGames: reviewGames)
    }
    
    // RankService.shared.reloadScores()
    
    // Build a unique list of all participants across all matches
    if let matches = matches {
      let allPlayers: [GKPlayer] = matches
        .flatMap { $0.participants }
        .compactMap { $0.player }
      // Deduplicate by playerID and sort for stable ordering
      var seen = Set<String>()
      let uniquePlayers = allPlayers.filter { p in
        if seen.contains(p.playerID) { return false }
        seen.insert(p.playerID)
        return true
      }.sorted { $0.playerID < $1.playerID }
      
      Task {
        for player in uniquePlayers {
          // await RankService.shared.ensureImage(for: player)
        }
      }
    }
  }
  
  func updateGames(
    currentGames: inout [GKTurnBasedMatch],
    newGames: [GKTurnBasedMatch]
  ) {
    // Remove games no longer present
    let newIDs = Set(newGames.map { $0.matchID })
    currentGames.removeAll { !newIDs.contains($0.matchID) }
    
    // Add new games not already present
    let currentIDs = Set(currentGames.map { $0.matchID })
    let gamesToAdd = newGames.filter { !currentIDs.contains($0.matchID) }
    currentGames.append(contentsOf: gamesToAdd)
    
    // Sort in place by time since last turn (most recent first)
    currentGames.sort(by: { (lhs: GKTurnBasedMatch, rhs: GKTurnBasedMatch) -> Bool in
      lhs.timeSinceLastTurn() > rhs.timeSinceLastTurn()
    })
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
