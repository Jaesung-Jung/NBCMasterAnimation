//
//  CubicTimingParametersViewController.swift
//  Animation
//
//  Created by 정재성 on 6/20/25.
//

import UIKit
import Then
import SnapKit

final class CubicTimingParametersViewController: UIViewController {
  let cubicCurveControl = CubicCurveControl()
  let controlPointLabel = Label().then {
    $0.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
    $0.text = "0.0"
    $0.textAlignment = .center
    $0.textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.systemGray.cgColor
  }

  let linearButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "Linear"
  }
  let easeInButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "EaseIn"
  }
  let easeOutButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "EaseOut"
  }
  let easeInOutButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "EaseInOut"
  }

  let previewView = AnimationPreviewView {
    $0.frame.origin.x = $1.minX
  } animations: { item, rect, _ in
    if item.transform == .identity {
      item.transform = CGAffineTransform(translationX: rect.maxX - item.frame.width, y: 0)
    } else {
      item.transform = .identity
    }
  }

  let durationSlider = UISlider().then {
    $0.value = 1
    $0.maximumValue = 3
    $0.minimumValue = 0.1
  }

  let playButton = UIButton(configuration: .filled()).then {
    $0.configuration?.image = UIImage(systemName: "play.fill")
    $0.configuration?.title = "Play"
    $0.configuration?.buttonSize = .large
    $0.configuration?.imagePadding = 8
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Cubic Timing Parameters"
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
    updateUI()

    // Layout

    let scrollView = UIScrollView().then {
      $0.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 20)
    }
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    scrollView.addSubview(cubicCurveControl)
    cubicCurveControl.snp.makeConstraints {
      $0.top.equalTo(scrollView.contentLayoutGuide)
      $0.centerX.equalToSuperview()
      $0.size.equalTo(200)
    }

    scrollView.addSubview(controlPointLabel)
    controlPointLabel.snp.makeConstraints {
      $0.top.equalTo(cubicCurveControl.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
    }

    let builtInCurveButtons = UIStackView(axis: .vertical, distribution: .fillEqually, spacing: 10) {
      UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        linearButton
        easeInOutButton
      }
      UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        easeInButton
        easeOutButton
      }
    }
    scrollView.addSubview(builtInCurveButtons)
    builtInCurveButtons.snp.makeConstraints {
      $0.top.equalTo(controlPointLabel.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
    }

    scrollView.addSubview(previewView)
    previewView.snp.makeConstraints {
      $0.top.equalTo(builtInCurveButtons.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.height.equalTo(previewView.snp.width).multipliedBy(0.2)
    }

    let durationLabel = Label().then {
      $0.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
      $0.text = "1.0"
    }
    scrollView.addSubview(durationLabel)
    scrollView.addSubview(durationSlider)
    durationLabel.snp.makeConstraints {
      $0.leading.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.centerY.equalTo(durationSlider)
      $0.width.equalTo(35)
    }
    durationSlider.snp.makeConstraints {
      $0.top.equalTo(previewView.snp.bottom).offset(20)
      $0.leading.equalTo(durationLabel.snp.trailing).offset(8)
      $0.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
    }

    scrollView.addSubview(playButton)
    playButton.snp.makeConstraints {
      $0.top.equalTo(durationSlider.snp.bottom).offset(40)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.bottom.equalTo(scrollView.contentLayoutGuide)
    }

    // Actions

    let curveValueChangedAction = UIAction { [unowned self] action in
      updateUI()
    }
    cubicCurveControl.addAction(curveValueChangedAction, for: .valueChanged)

    let linearAction = UIAction { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .linear), animated: true)
      updateUI()
    }
    linearButton.addAction(linearAction, for: .primaryActionTriggered)

    let easeInAction = UIAction { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .easeIn), animated: true)
      updateUI()
    }
    easeInButton.addAction(easeInAction, for: .primaryActionTriggered)

    let easeOutAction = UIAction { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .easeOut), animated: true)
      updateUI()
    }
    easeOutButton.addAction(easeOutAction, for: .primaryActionTriggered)

    let easeInOutAction = UIAction { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .easeInOut), animated: true)
      updateUI()
    }
    easeInOutButton.addAction(easeInOutAction, for: .primaryActionTriggered)

    let sliderAction = UIAction { [unowned self] _ in
      durationSlider.value = (durationSlider.value * 10).rounded() / 10
      durationLabel.text = "\(durationSlider.value.formatted(.number.precision(.fractionLength(1))))"
    }
    durationSlider.addAction(sliderAction, for: .valueChanged)

    let playAction = UIAction { [unowned self] _ in
      playButton.isEnabled = false

      let timingParameters = UICubicTimingParameters(
        controlPoint1: cubicCurveControl.controlPoint1,
        controlPoint2: cubicCurveControl.controlPoint2
      )
      previewView.startAnimation(timingParameters, duration: TimeInterval(durationSlider.value)) { [unowned self] in
        playButton.isEnabled = true
      }
    }
    playButton.addAction(playAction, for: .primaryActionTriggered)
  }
}

// MARK: - CubicTimingParametersViewController (Private)

extension CubicTimingParametersViewController {
  private func updateUI() {
    controlPointLabel.attributedText = attributedString(cp1: cubicCurveControl.controlPoint1, cp2: cubicCurveControl.controlPoint2)
  }

  private func attributedString(cp1: CGPoint, cp2: CGPoint) -> NSAttributedString {
    let cp1 = cubicCurveControl.controlPoint1
    let cp2 = cubicCurveControl.controlPoint2
    let format: (CGFloat) -> String = {
      Float($0).formatted(.number.precision(.fractionLength(3)))
    }

    let attributedString = NSMutableAttributedString()
    attributedString.append(NSAttributedString(string: "x1:", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: format(cp1.x), attributes: [.foregroundColor: UIColor.systemGreen]))
    attributedString.append(NSAttributedString(string: ",", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: "y1:", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: format(cp1.y), attributes: [.foregroundColor: UIColor.systemGreen]))
    attributedString.append(NSAttributedString(string: ",", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: "x2:", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: format(cp2.x), attributes: [.foregroundColor: UIColor.systemBlue]))
    attributedString.append(NSAttributedString(string: ",", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: "y2:", attributes: [.foregroundColor: UIColor.systemGray]))
    attributedString.append(NSAttributedString(string: format(cp2.y), attributes: [.foregroundColor: UIColor.systemBlue]))
    return attributedString
  }
}

// MARK: - CubicTimingParametersViewController Preview

#Preview {
  NavigationController(rootViewController: CubicTimingParametersViewController())
}
