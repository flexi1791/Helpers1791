//
//  NSError+Helpers.swift
//  Conversation
//
//  Created by Felix Andrew Work on 2/19/25.
//
import Foundation

extension Error {
  var underlyingErrors: String {
    let nsError = self as NSError
    if let underlyingErrors = nsError.userInfo[NSUnderlyingErrorKey] as? [NSError] {
      return underlyingErrors.map { $0.localizedDescription }.joined(separator: ", ")
    } else if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
      return underlyingError.localizedDescription
    }
    return localizedDescription
  }
}

extension NSError {
  var underlying: String {
    let nsError = self as NSError
    if let underlyingErrors = nsError.userInfo[NSUnderlyingErrorKey] as? [NSError] {
      return underlyingErrors.map { $0.localizedDescription }.joined(separator: ", ")
    } else if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
      return underlyingError.localizedDescription
    }
    return localizedDescription
  }
}
