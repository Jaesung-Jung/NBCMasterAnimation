//
//  GradientView.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

final class GradientView: UIView {
  private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

  override class var layerClass: AnyClass { CAGradientLayer.self }

  @inlinable var style: GradientView.Style {
    get { Style(rawValue: gradientLayer.type.rawValue) }
    set { gradientLayer.type = CAGradientLayerType(rawValue: newValue.rawValue) }
  }

  @inlinable var colors: [UIColor]? {
    get { gradientLayer.colors?.map { UIColor(cgColor: $0 as! CGColor) } }  // swiftlint:disable:this force_cast
    set { gradientLayer.colors = newValue?.map(\.cgColor) }
  }

  @inlinable var locations: [Float]? {
    get { gradientLayer.locations?.map { $0.floatValue } }
    set { gradientLayer.locations = newValue?.map { NSNumber(value: $0) } }
  }

  @inlinable var startPoint: CGPoint {
    get { gradientLayer.startPoint }
    set { gradientLayer.startPoint = newValue }
  }

  @inlinable var endPoint: CGPoint {
    get { gradientLayer.endPoint }
    set { gradientLayer.endPoint = newValue }
  }

  convenience init(style: GradientView.Style? = nil, colors: [UIColor]? = nil, locations: [Float]? = nil, startPoint: CGPoint? = nil, endPoint: CGPoint? = nil) {
    self.init(frame: .zero)
    if let style {
      self.style = style
    }
    if let colors {
      self.colors = colors
    }
    if let locations {
      self.locations = locations
    }
    if let startPoint {
      self.startPoint = startPoint
    }
    if let endPoint {
      self.endPoint = endPoint
    }
  }
}

// MARK: - GradientView.Style

extension GradientView {
  struct Style: RawRepresentable {
    let rawValue: String

    init(rawValue: String) {
      self.rawValue = rawValue
    }

    init(_ type: CAGradientLayerType) {
      self.init(rawValue: type.rawValue)
    }

    static let axial = Style(.axial)
    static let conic = Style(.conic)
    static let radial = Style(.radial)
  }
}

// MARK: - GradientView Preview

#Preview {
  GradientView(style: .axial, colors: [.systemBlue, .systemGreen], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1))
}
