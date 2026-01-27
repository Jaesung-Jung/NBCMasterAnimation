//
//  Menu.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

enum Menu: CustomStringConvertible {
  case basicAnimation
  case cubicParameters
  case springParameters
  case controlAnimation

  case collision
  case gravity
  case attachment
  case snap
  case push

  case alertTransition
  case matchTransition

  case lottie

  var image: UIImage {
    switch self {
    case .basicAnimation:
      UIImage(
        systemName: "point.bottomleft.filled.forward.to.point.topright.scurvepath",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
      )!
    case .cubicParameters:
      UIImage(
        systemName: "beziercurve",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
      )!
    case .springParameters:
      UIImage(
        systemName: "waveform.path.ecg",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
      )!
    case .controlAnimation:
      UIImage(
        systemName: "slider.horizontal.3",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
      )!
    case .collision:
      UIImage(
        systemName: "arrow.down.to.line",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
      )!
    case .gravity:
      UIImage(
        systemName: "circle.circle",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
      )!
    case .attachment:
      UIImage(
        systemName: "link",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
      )!
    case .snap:
      UIImage(
        systemName: "rectangle.on.rectangle.dashed",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
      )!
    case .push:
      UIImage(
        systemName: "arrow.up.and.down.and.arrow.left.and.right",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemIndigo)
      )!
    case .alertTransition:
      UIImage(
        systemName: "inset.filled.tophalf.bottomleft.bottomright.rectangle",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
      )!
    case .matchTransition:
      UIImage(
        systemName: "rectangle.on.rectangle",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
      )!
    case .lottie:
      UIImage(
        systemName: "sparkles.square.filled.on.square",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
      )!
    }
  }

  var description: String {
    switch self {
    case .basicAnimation:
      return "Basic Animation"
    case .cubicParameters:
      return "Cubic Timing Parameters"
    case .springParameters:
      return "Spring Timing Parameters"
    case .controlAnimation:
      return "Control Animation"
    case .collision:
      return "Collision"
    case .gravity:
      return "Gravity"
    case .attachment:
      return "Attachment"
    case .snap:
      return "Snap"
    case .push:
      return "Push"
    case .alertTransition:
      return "Alert Transition"
    case .matchTransition:
      return "Match Transition"
    case .lottie:
      return "Lottie"
    }
  }
}
