//
//  UIKit+Extensions.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit

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
    .systemRed,
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
