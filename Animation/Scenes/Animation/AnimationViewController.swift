//
//  AnimationViewController.swift
//  Animation
//
//  Created by 정재성 on 6/18/25.
//

import UIKit
import SnapKit
import Then

final class AnimationViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Animation"
    view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    // Curve
    let curveView = CubicCuverView()
    view.addSubview(curveView)
    curveView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.centerX.equalToSuperview()
      $0.size.equalTo(250)
    }

    // Builtin Curve
    let curveButtonStackView = UIStackView(axis: .vertical, spacing: 10) {
      UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        UIButton(configuration: .filled(title: "Linear")) {
          curveView.cubicTimingParameters = UICubicTimingParameters(animationCurve: .linear)
        }
        UIButton(configuration: .filled(title: "EaseInOut")) {
          curveView.cubicTimingParameters = UICubicTimingParameters(animationCurve: .easeInOut)
        }
      }
      UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        UIButton(configuration: .filled(title: "EaseIn")) {
          curveView.cubicTimingParameters = UICubicTimingParameters(animationCurve: .easeIn)
        }
        UIButton(configuration: .filled(title: "EaseOut")) {
          curveView.cubicTimingParameters = UICubicTimingParameters(animationCurve: .easeOut)
        }
      }
    }
    view.addSubview(curveButtonStackView)
    curveButtonStackView.snp.makeConstraints {
      $0.top.equalTo(curveView.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(view.directionalLayoutMargins)
    }
//
//    // Slider
//    let sliderStackView = UIStackView(axis: .vertical, spacing: 10) {
//      UIStackView(axis: .horizontal, spacing: 10) {
//        UILabel("controlPoint1")
//        UISlider { value in
//          let controlPoint2 = curveView.cubicTimingParameters.controlPoint2
//        }
//      }
//      UIStackView(axis: .horizontal, spacing: 10) {
//        UILabel("controlPoint2")
//        UISlider { value in
//        }
//      }
//    }
//    view.addSubview(sliderStackView)
//    sliderStackView.snp.makeConstraints {
//      $0.top.equalTo(curveButtonStackView.snp.bottom).offset(20)
//      $0.leading.trailing.equalTo(view.directionalLayoutMargins)
//    }
  }
}

extension UIButton.Configuration {
  @inlinable static func small() -> UIButton.Configuration {
    var configuration = UIButton.Configuration.tinted()
    configuration.buttonSize = .small
    configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = UIFont.systemFont(ofSize: 13)
      return outgoing
    }
    return configuration
  }
}

// MARK: - AnimationViewController Preview

#Preview {
  UINavigationController(rootViewController: AnimationViewController())
}

//import SwiftUI
//
//struct CubicBezierCurveView: View {
//  let controlPoint1: CGPoint
//  let controlPoint2: CGPoint
//  let steps: Int
//
//  var body: some View {
//    GeometryReader { geometry in
//      let size = min(geometry.size.width, geometry.size.height)
//      let margin: CGFloat = 20
//      let drawSize = size - margin * 2
//
//      Path { path in
//        let start = CGPoint(x: 0, y: drawSize)
//        let end = CGPoint(x: drawSize, y: 0)
//        let cp1 = CGPoint(
//          x: controlPoint1.x * drawSize,
//          y: drawSize - controlPoint1.y * drawSize
//        )
//        let cp2 = CGPoint(
//          x: controlPoint2.x * drawSize,
//          y: drawSize - controlPoint2.y * drawSize
//        )
//
//        path.move(to: start)
//        path.addCurve(to: end, control1: cp1, control2: cp2)
//      }
//      .stroke(Color.purple, lineWidth: 3)
//      .background(
//        // 격자 그리기 (옵션)
//        GridLines()
//          .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//      )
//      .padding(margin)
//    }
//    .aspectRatio(1, contentMode: .fit)
//  }
//}
//
//// (옵션) 5x5 격자 그리기용 Shape
//struct GridLines: Shape {
//  func path(in rect: CGRect) -> Path {
//    var path = Path()
//    let step = rect.width / 4
//    for i in 0...4 {
//      let x = CGFloat(i) * step
//      path.move(to: CGPoint(x: x, y: 0))
//      path.addLine(to: CGPoint(x: x, y: rect.height))
//      path.move(to: CGPoint(x: 0, y: x))
//      path.addLine(to: CGPoint(x: rect.width, y: x))
//    }
//    return path
//  }
//}
//
//// 사용 예시
//struct ContentView: View {
//  var body: some View {
//    CubicBezierCurveView(
//      controlPoint1: CGPoint(x: 0.75, y: 0.1),
//      controlPoint2: CGPoint(x: 0.9, y: 0.25),
//      steps: 100
//    )
//    .frame(width: 300, height: 300)
//  }
//}
//
//#Preview {
//  ContentView()
//}
