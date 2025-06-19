//
//  CubicCuverView.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import SwiftUI
import HostingView

final class CubicCuverView: UIView {
  private let contentView: StatefulHostingView<UICubicTimingParameters>

  @inlinable var cubicTimingParameters: UICubicTimingParameters {
    get { contentView.state }
    set { contentView.state = newValue }
  }

  override var intrinsicContentSize: CGSize {
    CGSize(width: 200, height: 200)
  }

  override init(frame: CGRect) {
    self.contentView = StatefulHostingView(state: UICubicTimingParameters(animationCurve: .easeOut)) { _ in
      ContentView(
        controlPoint1: CGPoint(x: 0, y: 1),
        controlPoint2: CGPoint(x: 1, y: 0)
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
    UIViewPropertyAnimator(
      duration: 1,
      timingParameters: UICubicTimingParameters(
        controlPoint1: CGPoint(x: 0, y: 1),
        controlPoint2: CGPoint(x: 1, y: 0)
      )
    )
  }
}

// MARK: - CubicCuverView.ContentView

extension CubicCuverView {
  private struct ContentView: View {
    @State var beginControlPoint1: CGPoint?
    @State var beginControlPoint2: CGPoint?
    @State var controlPoint1: CGPoint
    @State var controlPoint2: CGPoint

    var body: some View {
      GeometryReader { proxy in
        let frame = proxy.frame(in: .local)
        CubicBezierShape(controlPoint1: controlPoint1, controlPoint2: controlPoint2)
          .stroke(
            .linearGradient(colors: [.green, .blue], startPoint: .bottomLeading, endPoint: .topTrailing),
            style: StrokeStyle(lineWidth: 4, lineCap: .round)
          )
          .animation(beginControlPoint1 == nil ? .smooth : nil, value: controlPoint1)
          .animation(beginControlPoint2 == nil ? .smooth : nil, value: controlPoint2)
          .background {
            ZStack {
              Path {
                let stride = frame.width / 3
                for step in 1..<3 {
                  let offset = CGFloat(step) * stride
                  $0.move(to: CGPoint(x: frame.minX, y: frame.minY + offset))
                  $0.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + offset))
                  $0.move(to: CGPoint(x: frame.minX + offset, y: frame.minY))
                  $0.addLine(to: CGPoint(x: frame.minX + offset, y: frame.maxY))
                }
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
//          .overlay {
//            ZStack {
//              Path {
//                $0.move(to: CGPoint(x: frame.minX, y: frame.maxY))
//                $0.addLine(
//                  to: CGPoint(
//                    x: frame.minX + frame.maxX * controlPoint1.x,
//                    y: frame.maxY - frame.maxY * controlPoint1.y
//                  )
//                )
//              }
//              .stroke(.green, style: StrokeStyle(lineWidth: 4))
//
//              Path {
//                $0.move(to: CGPoint(x: frame.maxX, y: frame.minY))
//                $0.addLine(
//                  to: CGPoint(
//                    x: frame.minX + frame.maxX * controlPoint2.x,
//                    y: frame.maxY - frame.maxY * controlPoint2.y
//                  )
//                )
//              }
//              .stroke(.blue, style: StrokeStyle(lineWidth: 4))
//            }
//          }
//          .overlay {
//            Circle()
//              .fill(.background)
//              .stroke(.green, lineWidth: 4)
//              .frame(width: 15, height: 15, alignment: .topLeading)
//              .offset(
//                x: (controlPoint1.x - 0.5) * frame.maxX,
//                y: frame.maxY * 0.5 - frame.maxY * controlPoint1.y
//              )
//              .gesture(DragGesture()
//                .onChanged { value in
//                  if beginControlPoint1 == nil {
//                    beginControlPoint1 = controlPoint1
//                  }
//                  let controlPoint = beginControlPoint1 ?? controlPoint1
//                  controlPoint1 = CGPoint(
//                    x: min(max(0, controlPoint.x + value.translation.width / frame.width), 1),
//                    y: min(max(0, controlPoint.y - value.translation.height / frame.height), 1)
//                  )
//                }
//                .onEnded { _ in
//                  beginControlPoint1 = nil
//                }
//              )
//
//            Circle()
//              .fill(.background)
//              .stroke(.blue, lineWidth: 4)
//              .frame(width: 15, height: 15, alignment: .topLeading)
//              .offset(
//                x: (controlPoint2.x - 0.5) * frame.maxX,
//                y: frame.maxY * 0.5 - frame.maxY * controlPoint2.y
//              )
//              .gesture(DragGesture()
//                .onChanged { value in
//                  if beginControlPoint2 == nil {
//                    beginControlPoint2 = controlPoint2
//                  }
//                  let controlPoint = beginControlPoint2 ?? controlPoint2
//                  controlPoint2 = CGPoint(
//                    x: min(max(0, controlPoint.x + value.translation.width / frame.width), 1),
//                    y: min(max(0, controlPoint.y - value.translation.height / frame.height), 1)
//                  )
//                }
//                .onEnded { _ in
//                  beginControlPoint2 = nil
//                }
//              )
//          }
      }
      .padding(10)
      .onAppear {
        print("\(controlPoint1), \(controlPoint2)")
      }
    }
  }
}

// MARK: - CubicCuverView.CubicBezierShape

extension CubicCuverView {
  private struct CubicBezierShape: Shape {
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
      var path = Path()
      path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
      path.addCurve(
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
      return path
    }
  }
}

// MARK: - CubicCuverView Preview

#Preview {
  CubicCuverView()
}
