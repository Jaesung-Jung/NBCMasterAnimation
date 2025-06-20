//
//  CubicCurveControl.swift
//  Animation
//
//  Created by 정재성 on 6/20/25.
//

import SwiftUI
import Then
import SnapKit
import HostingView

final class CubicCurveControl: UIControl {
  private let contentView: StatefulHostingView<(CGPoint, CGPoint, Bool)>
  private var controlTarget: ControlTarget?

  @inlinable var controlPoint1: CGPoint { contentView.state.0 }
  @inlinable var controlPoint2: CGPoint { contentView.state.1 }

  override init(frame: CGRect) {
    let controlPoint1 = CGPoint(x: 0, y: 0)
    let controlPoint2 = CGPoint(x: 1, y: 1)
    contentView = StatefulHostingView(state: (controlPoint1, controlPoint2, false)) {
      ContentView(controlPoint1: $0, controlPoint2: $1, animated: $2)
    }
    super.init(frame: frame)
    addSubview(contentView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    guard let touch = touches.first else {
      return
    }
    let location = touch.location(in: self)
    let d1 = distance(from: location, to: point(for: controlPoint1, in: bounds))
    let d2 = distance(from: location, to: point(for: controlPoint2, in: bounds))

    let tolerance: CGFloat = 40
    guard d1 <= tolerance || d2 <= tolerance else {
      return
    }
    if d1 < d2 {
      controlTarget = .controlPoint1(controlPoint: controlPoint1, touchLocation: location)
    } else {
      controlTarget = .controlPoint2(controlPoint: controlPoint2, touchLocation: location)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    guard let controlTarget, let touch = touches.first else {
      return
    }
    let location = touch.location(in: self)
    let translation = CGPoint(
      x: location.x - controlTarget.touchLocation.x,
      y: location.y - controlTarget.touchLocation.y
    )
    let newControlPoint = CGPoint(
      x: min(max(0, controlTarget.controlPoint.x + (translation.x / bounds.width)), 1),
      y: min(max(0, controlTarget.controlPoint.y - (translation.y / bounds.height)), 1)
    )
    switch controlTarget {
    case .controlPoint1:
      contentView.state = (newControlPoint, controlPoint2, false)
    case .controlPoint2:
      contentView.state = (controlPoint1, newControlPoint, false)
    }
    sendActions(for: .valueChanged)
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    controlTarget = nil
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    controlTarget = nil
  }

  func setControlPoint1(_ p1: CGPoint, controlPoint2 p2: CGPoint, animated: Bool) {
    contentView.state = (p1, p2, animated)
  }

  func setCubicTimingParameters(_ parameters: UICubicTimingParameters, animated: Bool) {
    contentView.state = (parameters.controlPoint1, parameters.controlPoint2, animated)
  }
}

// MARK: - CubicCurveControl (Private)

extension CubicCurveControl {
  private func point(for controlPoint: CGPoint, in bounds: CGRect) -> CGPoint {
    CGPoint(
      x: controlPoint.x * bounds.width,
      y: bounds.maxY - controlPoint.y * bounds.height
    )
  }

  private func distance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return sqrt(dx * dx + dy * dy)
  }
}

// MARK: - CubicCurveControl.ControlTarget

extension CubicCurveControl {
  private enum ControlTarget {
    case controlPoint1(controlPoint: CGPoint, touchLocation: CGPoint)
    case controlPoint2(controlPoint: CGPoint, touchLocation: CGPoint)

    @inlinable var controlPoint: CGPoint {
      switch self {
      case .controlPoint1(let controlPoint, _), .controlPoint2(let controlPoint, _):
        return controlPoint
      }
    }

    @inlinable var touchLocation: CGPoint {
      switch self {
      case .controlPoint1(_, let location), .controlPoint2(_, let location):
        return location
      }
    }
  }
}

// MARK: - CubicCurveControl.ContentView

extension CubicCurveControl {
  private struct ContentView: View {
    let controlPoint1: CGPoint
    let controlPoint2: CGPoint
    let animated: Bool
    let startColor = Color.green
    let endColor = Color.blue

    @inlinable var animation: Animation? { animated ? .smooth : nil }

    var body: some View {
      GeometryReader { proxy in
        let frame = proxy.frame(in: .local)

        Path { // Dash line
          let stride = frame.width / 4
          for step in 1..<4 {
            let offset = CGFloat(step) * stride
            $0.move(to: CGPoint(x: frame.minX, y: frame.minY + offset))
            $0.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + offset))
            $0.move(to: CGPoint(x: frame.minX + offset, y: frame.minY))
            $0.addLine(to: CGPoint(x: frame.minX + offset, y: frame.maxY))
          }
        }
        .stroke(.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [0, 4], dashPhase: 2))

        Path { // Axis line
          $0.move(to: CGPoint(x: frame.minX, y: frame.minY))
          $0.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
          $0.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        }
        .stroke(.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round))

        // Curve
        BezierCurve(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
          .stroke(
            .linearGradient(colors: [startColor, endColor], startPoint: .bottom, endPoint: .top),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
          )
          .animation(animation, value: controlPoint1)
          .animation(animation, value: controlPoint2)
          .padding(2)

        ZStack { // Control Point 1
          ControlLine(controlPoint1) {
            CGPoint(x: $0.minX, y: $0.maxY)
          }
          .stroke(startColor, style: StrokeStyle(lineWidth: 2, dash: [4, 2]))

          Circle() // Control Circle
            .fill(.background)
            .stroke(startColor, lineWidth: 4)
            .frame(width: 15, height: 15, alignment: .topLeading)
            .offset(
              x: (controlPoint1.x - 0.5) * frame.maxX,
              y: frame.maxY * 0.5 - frame.maxY * controlPoint1.y
            )
        }
        .animation(animation, value: controlPoint1)

        ZStack {
          ControlLine(controlPoint2) {
            CGPoint(x: $0.maxX, y: $0.minY)
          }
          .stroke(endColor, style: StrokeStyle(lineWidth: 2, dash: [4, 2]))

          Circle() // Control Circle
            .fill(.background)
            .stroke(endColor, lineWidth: 4)
            .frame(width: 15, height: 15, alignment: .topLeading)
            .offset(
              x: (controlPoint2.x - 0.5) * frame.maxX,
              y: frame.maxY * 0.5 - frame.maxY * controlPoint2.y
            )
        }
        .animation(animation, value: controlPoint1)
      }
      .padding(10)
    }
  }
}

// MARK: - CubicCurveControl.BezierCurve

extension CubicCurveControl {
  private struct BezierCurve: Shape {
    var controlPoint1: CGPoint
    var controlPoint2: CGPoint

    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
      get {
        AnimatablePair(
          AnimatablePair(controlPoint1.x, controlPoint1.y),
          AnimatablePair(controlPoint2.x, controlPoint2.y)
        )
      }
      set {
        controlPoint1 = CGPoint(x: newValue.first.first, y: newValue.first.second)
        controlPoint2 = CGPoint(x: newValue.second.first, y: newValue.second.second)
      }
    }

    func path(in rect: CGRect) -> Path {
      Path {
        $0.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        $0.addCurve(
          to: CGPoint(x: rect.maxX, y: rect.minY),
          control1: CGPoint(
            x: rect.minX + controlPoint1.x * rect.width,
            y: rect.maxY - controlPoint1.y * rect.height
          ),
          control2: CGPoint(
            x: rect.minX + controlPoint2.x * rect.width,
            y: rect.maxY - controlPoint2.y * rect.height
          )
        )
      }
    }
  }
}

// MARK: - CubicCurveControl.ControlLine

extension CubicCurveControl {
  private struct ControlLine: Shape {
    let from: @Sendable (CGRect) -> CGPoint
    var controlPoint: CGPoint

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
      get { AnimatablePair(controlPoint.x, controlPoint.y) }
      set { controlPoint = CGPoint(x: newValue.first, y: newValue.second) }
    }

    init(_ controlPoint: CGPoint, from: @escaping @Sendable (CGRect) -> CGPoint) {
      self.controlPoint = controlPoint
      self.from = from
    }

    func path(in rect: CGRect) -> Path {
      var path = Path()
      path.move(to: from(rect))
      path.addLine(
        to: CGPoint(
          x: rect.minX + rect.maxX * controlPoint.x,
          y: rect.maxY - rect.maxY * controlPoint.y
        )
      )
      return path
    }
  }
}

// MARK: - CubicCurveControl Preview

#Preview {
  CubicCurveControl().then {
    $0.snp.makeConstraints {
      $0.size.equalTo(300)
    }
  }
}
