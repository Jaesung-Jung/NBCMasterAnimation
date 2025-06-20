//
//  SpringCurveView.swift
//  Animation
//
//  Created by 정재성 on 6/20/25.
//

import SwiftUI
import Then
import SnapKit
import HostingView

final class SpringCurveView: UIView {
  private let contentView: StatefulHostingView<SpringTimingParameters>

  @inlinable var mass: CGFloat {
    get { contentView.state.mass }
    set {
      contentView.state = SpringTimingParameters(
        mass: newValue,
        stiffness: contentView.state.stiffness,
        damping: contentView.state.damping,
        initialVelocity: contentView.state.initialVelocity
      )
    }
  }

  @inlinable var stiffness: CGFloat {
    get { contentView.state.stiffness }
    set {
      contentView.state = SpringTimingParameters(
        mass: contentView.state.mass,
        stiffness: newValue,
        damping: contentView.state.damping,
        initialVelocity: contentView.state.initialVelocity
      )
    }
  }

  @inlinable var damping: CGFloat {
    get { contentView.state.damping }
    set {
      contentView.state = SpringTimingParameters(
        mass: contentView.state.mass,
        stiffness: contentView.state.stiffness,
        damping: newValue,
        initialVelocity: contentView.state.initialVelocity
      )
    }
  }

  @inlinable var dampingRatio: CGFloat {
    get { contentView.state.dampingRatio }
    set {
      contentView.state = SpringTimingParameters(
        dampingRatio: newValue,
        response: contentView.state.response,
        initialVelocity: contentView.state.initialVelocity
      )
    }
  }

  override init(frame: CGRect) {
    let state = SpringTimingParameters(dampingRatio: 0.5, response: 1)
    contentView = StatefulHostingView(state: state) {
      ContentView(spring: $0)
    }
    super.init(frame: frame)
    addSubview(contentView)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
  }
}

// MARK: - SpringCurveView.ContentView

extension SpringCurveView {
  private struct ContentView: View {
    let spring: SpringTimingParameters
    let startColor = Color.green
    let endColor = Color.blue

    var body: some View {
      GeometryReader { proxy in
        let frame = proxy.frame(in: .local)
        let critical: CGFloat = 0.5
        Path { // Curve
          let rect = CGRect(
            x: frame.minX,
            y: frame.minY + frame.height * (1 - critical),
            width: frame.width,
            height: frame.height * critical
          )
          let samples = 300
          for offset in 0..<samples {
            let t = CGFloat(offset) / CGFloat(samples - 1) * spring.duration
            let x = CGFloat(offset) / CGFloat(samples - 1) * rect.width
            let y = rect.minY + rect.height * (1 - spring.value(at: t))
            if offset == 0 {
              $0.move(to: CGPoint(x: x, y: y))
            } else {
              $0.addLine(to: CGPoint(x: x, y: y))
            }
          }
        }
        .stroke(
          .linearGradient(colors: [startColor, endColor], startPoint: .leading, endPoint: .trailing),
          style: StrokeStyle(lineWidth: 4, lineCap: .round)
        )
        .clipShape(Rectangle())

        Path { // Dash line
          let y = frame.maxY * (1 - critical)
          $0.move(to: CGPoint(x: frame.minX, y: y))
          $0.addLine(to: CGPoint(x: frame.maxX, y: y))
        }
        .stroke(.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [0, 4], dashPhase: 2))

        Path { // Axis line
          $0.move(to: CGPoint(x: frame.minX, y: frame.minY))
          $0.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
          $0.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
        }
        .stroke(.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round))
      }
    }
  }
}

// MARK: - SpringCurveView.State

extension SpringCurveView {
  private struct State {
    var mass: CGFloat = 0.5
    var stiffness: CGFloat = 150
    var damping: CGFloat = 10
  }
}

// MARK: - SpringCurveView.SpringTimingParameters

extension SpringCurveView {
  private struct SpringTimingParameters {
    let mass: CGFloat
    let stiffness: CGFloat
    let damping: CGFloat
    let initialVelocity: CGFloat
    let duration: CGFloat

    @inlinable var dampingRatio: CGFloat { damping / (2 * sqrt(stiffness * mass)) }
    @inlinable var response: CGFloat { 2 * .pi / sqrt(stiffness / mass) }

    init(mass: CGFloat, stiffness: CGFloat, damping: CGFloat, initialVelocity: CGFloat) {
      self.mass = mass
      self.stiffness = stiffness
      self.damping = damping
      self.initialVelocity = initialVelocity
      let omegaN = sqrt(stiffness / mass)
      let zeta = damping / (2 * sqrt(stiffness * mass))
      self.duration = zeta == 0 ? 0 : log(1 / 0.001) / (zeta * omegaN)
    }

    init(dampingRatio: CGFloat, response: CGFloat, initialVelocity: CGFloat = .zero) {
      let mass: CGFloat = 1
      let stiffness = pow((2 * .pi) / response, 2) * mass
      self.init(
        mass: mass,
        stiffness: pow((2 * .pi) / response, 2) * mass,
        damping: 2 * dampingRatio * sqrt(stiffness * mass),
        initialVelocity: initialVelocity
      )
    }

    func value(at time: CGFloat) -> CGFloat {
      let omegaN = sqrt(stiffness / mass)
      let zeta = damping / (2 * sqrt(stiffness * mass))

      let x0: CGFloat = 0
      let v0 = initialVelocity

      if zeta < 1 { // Underdamped
        let omegaD = omegaN * sqrt(1 - zeta * zeta)
        let A = 1 - x0
        let B = (v0 + zeta * omegaN * A) / omegaD
        let e = exp(-zeta * omegaN * time)
        return 1 - e * (A * cos(omegaD * time) + B * sin(omegaD * time))
      } else if zeta == 1 { // Critically damped
        let A = 1 - x0
        let B = v0 + omegaN * A
        let e = exp(-omegaN * time)
        return 1 - e * (A + B * time)
      } else { // Overdamped
        let r1 = -omegaN * (zeta - sqrt(zeta * zeta - 1))
        let r2 = -omegaN * (zeta + sqrt(zeta * zeta - 1))
        let A = (v0 - r2) / (r1 - r2)
        let B = 1 - A
        let e1 = A * exp(r1 * time)
        let e2 = B * exp(r2 * time)
        return 1 - (e1 + e2)
      }
    }
  }
}

// MARK: - SpringCurveView Preview

#Preview {
  SpringCurveView().then {
    $0.snp.makeConstraints {
      $0.size.equalTo(300)
    }
  }
}
