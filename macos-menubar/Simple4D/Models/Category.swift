//
//  Category.swift
//  Simple4D
//
//  Created by Prabodh Agarwal on 22/08/25.
//


  import Foundation

  enum Category: String, CaseIterable {
      case doIt = "do"
      case deferIt = "defer"
      case delegate = "delegate"
      case drop = "drop"

      var listName: String {
          switch self {
          case .doIt: return "4D - Do"
          case .deferIt: return "4D - Defer"
          case .delegate: return "4D - Delegate"
          case .drop: return "4D - Drop"
          }
      }

      var symbolName: String {
          switch self {
          case .doIt: return "1.square"
          case .deferIt: return "2.square"
          case .delegate: return "3.square"
          case .drop: return "4.square"
          }
      }

      var displayName: String {
          switch self {
          case .doIt: return "Do"
          case .deferIt: return "Defer"
          case .delegate: return "Delegate"
          case .drop: return "Drop"
          }
      }
  }
