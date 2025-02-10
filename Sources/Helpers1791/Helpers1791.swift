// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct FallbackImage {
  public let image: Image
  
  public init(_ filename: String) {
    if let uiImage = UIImage(named: filename) {
      self.image = Image(uiImage: uiImage)
    } else {
      let bundle = Bundle(identifier: "com.1791entertainment.Corporate-Mystic.SharedResoures")
      if let uiImage = UIImage(named: filename, in: bundle, compatibleWith: nil) {
        self.image = Image(uiImage: uiImage)
      } else {
        self.image = Image(systemName: "xmark")
        print("Cannot load \(filename) from bundle \(String(describing: bundle))")
      }
    }
  }
}

