//
//  UIKit+Extensions.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit

extension UITimingCurveProvider where Self == UISpringTimingParameters {
  @inlinable static func spring(duration: TimeInterval, bounce: CGFloat, initialVelocity: CGVector) -> UISpringTimingParameters {
    if #available(iOS 17.0, *) {
      return UISpringTimingParameters(duration: duration, bounce: bounce, initialVelocity: initialVelocity)
    }
    let dampingRatio: CGFloat
    if bounce >= 0 {
      dampingRatio = 1 - bounce
    } else {
      dampingRatio = 1 / (1 + bounce)
    }
    return UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: initialVelocity)
  }

  static func smooth(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
    spring(duration: duration, bounce: 0.0, initialVelocity: initialVelocity)
  }

  static func snappy(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
    spring(duration: duration, bounce: 0.15, initialVelocity: initialVelocity)
  }

  static func bouncy(duration: CGFloat, initialVelocity: CGVector = .zero) -> UISpringTimingParameters {
    spring(duration: duration, bounce: 0.3, initialVelocity: initialVelocity)
  }
}

// MARK: - UIStackView

extension UIStackView {
  convenience init(
    axis: NSLayoutConstraint.Axis,
    distribution: UIStackView.Distribution = .fill,
    alignment: UIStackView.Alignment = .fill,
    spacing: CGFloat = 0,
    @ArrangedSubviewBuilder<UIView> arrangedSubviews: () -> [UIView]
  ) {
    self.init(arrangedSubviews: arrangedSubviews())
    self.axis = axis
    self.distribution = distribution
    self.alignment = alignment
    self.spacing = spacing
  }
}

// MARK: - UIStackView.ArrangedSubviewBuilder

extension UIStackView {
  @resultBuilder struct ArrangedSubviewBuilder<Item: UIView> {
    static func buildBlock(_ items: Item...) -> [Item] {
      items
    }

    static func buildBlock(_ items: [Item]...) -> [Item] {
      items.flatMap { $0 }
    }

    static func buildOptional(_ items: [Item]?) -> [Item] {
      items ?? []
    }

    static func buildEither(first items: [Item]) -> [Item] {
      items
    }

    static func buildEither(second items: [Item]) -> [Item] {
      items
    }

    static func buildExpression(_ expression: Item) -> [Item] {
      [expression]
    }

    static func buildExpression<C: Collection>(_ expression: C) -> [Item] where C.Element == Item {
      Array(expression)
    }

    static func buildArray(_ components: [[Item]]) -> [Item] {
      components.flatMap { $0 }
    }

    static func buildLimitedAvailability(_ component: [Item]) -> [Item] {
      component
    }
  }
}

// MARK: - UIColor

extension UIColor {
  private static let systemColors: [UIColor] = [
    systemRed,
    systemGreen,
    systemBlue,
    systemOrange,
    systemYellow,
    systemPink,
    systemPurple,
    systemTeal,
    systemIndigo,
    systemBrown,
    systemMint,
    systemCyan
  ]

  static var systemRandomColor: UIColor {
    systemColors[.random(in: 0..<systemColors.count)]
  }
}
