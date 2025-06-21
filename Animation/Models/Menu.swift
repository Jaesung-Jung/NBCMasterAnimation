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
  case animationControl

  case notificationTransition
  case seamlessTransition

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
    case .animationControl:
      UIImage(
        systemName: "slider.horizontal.3",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
      )!
    case .notificationTransition:
      UIImage(
        systemName: "widget.medium",
        withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
      )!
    case .seamlessTransition:
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
    case .animationControl:
      return "Animation Control"
    case .notificationTransition:
      return "Notification Transition"
    case .seamlessTransition:
      return "Seamless Transition"
    case .lottie:
      return "Lottie Preview"
    }
  }
}
