//
//  SpringCurveView.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import SwiftUI
import HostingView

final class SpringCurveView: UIView {
  private let contentView: StatefulHostingView<UICubicTimingParameters>

  override var intrinsicContentSize: CGSize {
    CGSize(width: 300, height: 200)
  }

  override init(frame: CGRect) {
    self.contentView = StatefulHostingView(state: UICubicTimingParameters(animationCurve: .easeOut)) {
      ContentView(
        controlPoint1: $0.controlPoint1,
        controlPoint2: $0.controlPoint2
      )
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
    @State var beginControlPoint1: CGPoint?
    @State var beginControlPoint2: CGPoint?
    @State var controlPoint1: CGPoint
    @State var controlPoint2: CGPoint

    var body: some View {
      GeometryReader { proxy in
        let frame = proxy.frame(in: .local)
        curvePath(curve: flattenedSpring, in: frame)
          .stroke(
            .linearGradient(colors: [.green, .blue], startPoint: .bottomLeading, endPoint: .topTrailing),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
          )
        .background {
          ZStack {
            Path {
              $0.move(to: CGPoint(x: frame.minX, y: frame.minY))
              $0.addLine(to: CGPoint(x: frame.maxX, y: frame.minY))
            }
            .stroke(.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [0, 4], dashPhase: 2))

            Path {
              $0.move(to: CGPoint(x: frame.minX, y: frame.minY))
              $0.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
              $0.addLine(to: CGPoint(x: frame.maxX, y: frame.maxY))
            }
            .stroke(.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round))
          }
        }
      }
      .padding(10)
      .onAppear {
        print("\(controlPoint1), \(controlPoint2)")
      }
    }

    func bouncySpring(_ t: Double) -> Double {
      // damping < 1.0
      let damping: Double = 0.55
      let frequency: Double = 2.2
      let pi = Double.pi
      let ω0 = frequency * 2 * pi
      let d = damping
      let sqrtOneMinusDamping2 = sqrt(1.0 - d * d)
      let envelope = exp(-d * ω0 * t)
      return 1 - envelope * (cos(ω0 * sqrtOneMinusDamping2 * t) + (d / sqrtOneMinusDamping2) * sin(ω0 * sqrtOneMinusDamping2 * t))
    }

    // Smooth: critically damped (bounce == 0)
    func smoothSpring(_ t: Double) -> Double {
      // damping == 1.0
      let damping: Double = 1.0
      let frequency: Double = 2.2
      let pi = Double.pi
      let ω0 = frequency * 2 * pi
      let envelope = exp(-ω0 * t)
      return 1 - envelope * (1 + ω0 * t)
    }

    // Flattened: overdamped (bounce < 0)
    func flattenedSpring(_ t: Double) -> Double {
      // damping > 1.0
      let damping: Double = 1.6
      let frequency: Double = 2.2
      let pi = Double.pi
      let ω0 = frequency * 2 * pi
      let d = damping
      let sqrtDamping2MinusOne = sqrt(d * d - 1.0)
      let r1 = -ω0 * (d - sqrtDamping2MinusOne)
      let r2 = -ω0 * (d + sqrtDamping2MinusOne)
      let c2 = (r1 / (r1 - r2))
      let c1 = 1 - c2
      return 1 - (c1 * exp(r1 * t) + c2 * exp(r2 * t))
    }

    func curvePath(curve: (Double) -> Double, in rect: CGRect) -> Path {
      let steps = 200
      var path = Path()
      for i in 0...steps {
        let t = Double(i) / Double(steps)
        let y = curve(t)
        let px = rect.minX + CGFloat(t) * rect.width
        let py = rect.maxY - CGFloat(y) * rect.height // Y축 뒤집기
        if i == 0 {
          path.move(to: CGPoint(x: px, y: py))
        } else {
          path.addLine(to: CGPoint(x: px, y: py))
        }
      }
      return path
    }
  }
}

// MARK: - CubicCuverView Preview

#Preview {
  SpringCurveView()
}
