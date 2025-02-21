//
//  GKTurnBasedMatch+Helpers.swift
//  Helpers1791
//
//  Created by Felix Andrew Work on 2/21/25.
//
import SwiftUI
import GameKit

public extension GKTurnBasedMatch {
  // The next participant
  var nextParticipant : GKTurnBasedParticipant? {
    guard let current = self.currentParticipant else {
      return nil
    }
    
    guard let currentIndex = self.participants.firstIndex(of: current) else {
      return nil
    }
    
    let nextIndex = (currentIndex + 1) % self.participants.count
    return self.participants[nextIndex]
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
  
  var opponent: GKTurnBasedParticipant? {
    for participant in self.participants {
      if participant.player != GKLocalPlayer.local {
        return participant
      }
    }
    return nil
  }
  
  var areWeInvited: Bool {
    return self.participants.contains(where: { $0.player?.gamePlayerID == GKLocalPlayer.local.gamePlayerID && $0.status == .invited })
  }
  
  // Function to get the date of the most recent activity
  var mostRecentActivityDate: Date {
    // Start with a distant past date
    var mostRecentDate = self.creationDate
    
    // Check the turn dates of all participants
    for participant in self.participants {
      if let lastTurnDate = participant.lastTurnDate, lastTurnDate > mostRecentDate {
        mostRecentDate = lastTurnDate
      }
    }
    // Check the dates of the exchanges and find the most recent one
    if let exchanges = self.exchanges {
      let mostRecentExchangeDate = exchanges.compactMap { $0.sendDate }.max()
      if let mostRecentExchangeDate = mostRecentExchangeDate, mostRecentExchangeDate > mostRecentDate {
        mostRecentDate = mostRecentExchangeDate
      }
    }
    
    return mostRecentDate
  }
  
  var currentExchange : GKTurnBasedExchange? {
    return self.exchanges?.first(where: {
      $0.status == .active
    })
  }
  

  /*
  // Function to send a new exchange
  private func sendExchange(discussion: Discussion, completion: @escaping (Error?) -> Void) {
    do {
      let newData = try JSONEncoder().encode([discussion])
      self.sendExchange(
        to: [opponent!],
        data: newData,
        localizableMessageKey: "First message",
        arguments: [],
        timeout: TimeInterval(60)) { exchange, error in
          if let error = error {
            print("Error sending new exchange: \(error.localizedDescription)")
          }
          completion(error)
        }
    } catch {
      completion(error)
    }
  }
  
  // Function to handle received exchange requests
  func handleExchangeRequest(_ exchange: GKTurnBasedExchange, completion: @escaping (Error?, [Discussion]?) -> Void) {
    do {
      // Decode the array of discussions from the exchange data
      let discussions = try JSONDecoder().decode([Discussion].self, from: exchange.data!)
      // Process the discussions as needed
      completion(nil, discussions)
    } catch {
      completion(error, nil)
    }
  }
   */
  
  // Mark - typical resign, remind, delete functions
  //
  func resignMatch(completion: @escaping (Error?) -> Void) {
    if ourTurn {
      let dispatchGroup = DispatchGroup()
      
      // Fetch all unresolved exchanges
      let unresolvedExchanges = self.exchanges?.filter { $0.status == .active } ?? []
      
      // Resolve all unresolved exchanges
      for exchange in unresolvedExchanges {
        dispatchGroup.enter()
        exchange.cancel(withLocalizableMessageKey: "Exchange canceled", arguments: []) { error in
          if let error = error as? NSError {
            print("Error canceling exchange: \(error.underlying)")
            completion(error)
            dispatchGroup.leave()
            return
          }
          dispatchGroup.leave()
        }
        /*
         exchange.reply(withLocalizableMessageKey: "Exchange resolved", arguments: [], data: Data()) { error in
         if let error = error as? NSError {
         print("Error resolving exchange: \(error.underlying)")
         completion(error)
         dispatchGroup.leave()
         return
         }
         dispatchGroup.leave()
         }
         */
      }
      
      // Wait for all exchanges to be resolved
      dispatchGroup.notify(queue: .main) {
        if let nextParticipant = self.nextParticipant {
          self.participantQuitInTurn(with: .quit,
                                     nextParticipants: [nextParticipant],
                                     turnTimeout: 60,
                                     match: self.matchData ?? Data()) { error in
            if let error = error as? NSError {
              print("Error resigning match: \(error.underlyingErrors)")
            }
            completion(error)
          }
        }
      }
    } else {
      self.participantQuitOutOfTurn(with: .quit) { error in
        if let error = error as? NSError {
          print("Error resigning match: \(error.underlyingErrors)")
        }
        completion(error)
      }
    }
  }
  
  func sendReminder(reminder: String) {
    self.sendReminder(to: [self.opponent!],
                      localizableMessageKey: reminder,
                      arguments: []) { error in
      if let error = error {
        print("Error sending reminder: \(error.localizedDescription)")
      } else {
        print("Reminder sent successfully")
      }
    }
  }
  
  public func delete(completion: @escaping (Error?) -> Void) {
    self.remove() { error in
      completion(error)
    }
    completion(nil)
  }

}
