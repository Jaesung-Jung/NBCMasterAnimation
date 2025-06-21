//
//  CubicTimingParametersViewController.swift
//  Animation
//
//  Created by 정재성 on 6/20/25.
//

import UIKit
import Then
import SnapKit

final class CubicTimingParametersViewController: DetailViewController {
  let cubicCurveControl = CubicCurveControl()

  let controlPointLabel = Label().then {
    $0.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
    $0.textAlignment = .center
    $0.textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    $0.layer.cornerRadius = 8
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.systemGray.cgColor
  }

  let playButton = UIButton(configuration: .filled()).then {
    $0.configuration?.image = UIImage(systemName: "play.fill")
    $0.configuration?.title = "Play"
    $0.configuration?.buttonSize = .large
    $0.configuration?.imagePadding = 8
  }

  override var menu: Menu? { .cubicParameters }

  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()

    // Views

    let durationSlider = ValueSlider().then {
      $0.title = "duration"
      $0.value = 1
      $0.step = 0.1
      $0.maximumValue = 3
      $0.minimumValue = 0.1
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

    // Actions

    let linearAction = UIAction(title: "Linear") { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .linear), animated: true)
      updateUI()
    }

    let easeInAction = UIAction(title: "EaseIn") { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .easeIn), animated: true)
      updateUI()
    }

    let easeOutAction = UIAction(title: "EaseOut") { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .easeOut), animated: true)
      updateUI()
    }

    let easeInOutAction = UIAction(title: "EaseInOut") { [unowned self] _ in
      cubicCurveControl.setCubicTimingParameters(UICubicTimingParameters(animationCurve: .easeInOut), animated: true)
      updateUI()
    }

    let curveValueChangedAction = UIAction { [unowned self] action in
      updateUI()
    }
    cubicCurveControl.addAction(curveValueChangedAction, for: .valueChanged)

    let playAction = UIAction { [weak self] _ in
      guard let self else {
        return
      }
      playButton.isEnabled = false

      let timingParameters = UICubicTimingParameters(
        controlPoint1: cubicCurveControl.controlPoint1,
        controlPoint2: cubicCurveControl.controlPoint2
      )
      previewView.startAnimation(timingParameters, duration: TimeInterval(durationSlider.value)) { [weak self] in
        self?.playButton.isEnabled = true
      }
    }
    playButton.addAction(playAction, for: .primaryActionTriggered)

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
        UIButton(configuration: .tinted(), primaryAction: linearAction)
        UIButton(configuration: .tinted(), primaryAction: easeInOutAction)
      }
      UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        UIButton(configuration: .tinted(), primaryAction: easeInAction)
        UIButton(configuration: .tinted(), primaryAction: easeOutAction)
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

    scrollView.addSubview(durationSlider)
    durationSlider.snp.makeConstraints {
      $0.top.equalTo(previewView.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
    }

    scrollView.addSubview(playButton)
    playButton.snp.makeConstraints {
      $0.top.equalTo(durationSlider.snp.bottom).offset(40)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.bottom.equalTo(scrollView.contentLayoutGuide)
    }
  }
}

// MARK: - CubicTimingParametersViewController (Private)

extension CubicTimingParametersViewController {
  private func updateUI() {
    controlPointLabel.attributedText = attributedString(cp1: cubicCurveControl.controlPoint1, cp2: cubicCurveControl.controlPoint2)
  }

  private func attributedString(cp1: CGPoint, cp2: CGPoint) -> NSAttributedString {
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
