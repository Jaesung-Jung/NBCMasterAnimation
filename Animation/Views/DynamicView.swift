//
//  DynamicView.swift
//  Animation
//
//  Created by 정재성 on 1/27/26.
//

import UIKit
import Then

final class DynamicView: UIView {
  private let shapeLayer = CAShapeLayer().then {
    $0.lineWidth = 1
    $0.strokeColor = UIColor.systemGray4.cgColor
    $0.fillColor = UIColor.systemRandomColor.cgColor
    $0.shadowOpacity = 0
    $0.shadowColor = UIColor.black.cgColor
    $0.shadowOffset = CGSize(width: 0, height: 5)
    $0.shadowRadius = 5
  }

  let shape: Shape

  var color: UIColor? {
    get { shapeLayer.fillColor.map(UIColor.init) }
    set { shapeLayer.fillColor = newValue?.cgColor }
  }

  var shadowColor: UIColor? {
    get { shapeLayer.shadowColor.map(UIColor.init) }
    set { shapeLayer.shadowColor = newValue?.cgColor }
  }

  var shadowRadius: CGFloat {
    get { shapeLayer.shadowRadius }
    set { shapeLayer.shadowRadius = newValue }
  }

  var shadowOpacity: Float {
    get { shapeLayer.shadowOpacity }
    set { shapeLayer.shadowOpacity = newValue }
  }

  override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
    switch shape {
    case .rectangle:
      return .rectangle
    case .ellipse:
      return .ellipse
    }
  }

  init(shape: Shape, color: UIColor = .systemRandomColor) {
    self.shape = shape
    super.init(frame: .zero)
    layer.addSublayer(shapeLayer)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    shapeLayer.path = switch shape {
    case .rectangle:
      UIBezierPath(rect: bounds).cgPath
    case .ellipse:
      UIBezierPath(ovalIn: bounds).cgPath
    }
    shapeLayer.shadowPath = shapeLayer.path
  }
}

// MARK: - DynamicView.Shape

extension DynamicView {
  enum Shape {
    case rectangle
    case ellipse
  }
}
