//
//  SpringTimingParametersViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then
import SnapKit

final class SpringTimingParametersViewController: UIViewController {
  let springCurveControl = SpringCurveView()

  let massSlider = ValueSlider().then {
    $0.title = "mass"
    $0.step = 0.1
    $0.minimumValue = 0.1
    $0.maximumValue = 10
  }

  let stiffnessSlider = ValueSlider().then {
    $0.title = "stiffness"
    $0.step = 1
    $0.minimumValue = 50
    $0.maximumValue = 1000
  }

  let dampingSlider = ValueSlider().then {
    $0.title = "damping"
    $0.step = 1
    $0.minimumValue = 1
    $0.maximumValue = 15
  }

  let playButton = UIButton(configuration: .filled()).then {
    $0.configuration?.image = UIImage(systemName: "play.fill")
    $0.configuration?.title = "Play"
    $0.configuration?.buttonSize = .large
    $0.configuration?.imagePadding = 8
  }

  private func updateUI() {
    massSlider.value = Float(springCurveControl.mass)
    stiffnessSlider.value = Float(springCurveControl.stiffness)
    dampingSlider.value = Float(springCurveControl.damping)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Spring Timing Parameters"
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never
    updateUI()

    // Views
    let previewView = AnimationPreviewView {
      $0.frame.origin.x = $1.minX
      $0.layer.cornerRadius = $1.height * 0.5
    } animations: { item, rect, _ in
      if item.transform == .identity {
        item.transform = CGAffineTransform(translationX: rect.maxX - item.frame.width, y: 0)
      } else {
        item.transform = .identity
      }
    }

    // Actions

    let massAction = UIAction { [unowned self] _ in
      springCurveControl.mass = Double(massSlider.value)
      updateUI()
    }
    massSlider.addAction(massAction, for: .valueChanged)

    let stiffnessAction = UIAction { [unowned self] _ in
      springCurveControl.stiffness = Double(stiffnessSlider.value)
      updateUI()
    }
    stiffnessSlider.addAction(stiffnessAction, for: .valueChanged)

    let dampingAction = UIAction { [unowned self] _ in
      springCurveControl.damping = Double(dampingSlider.value)
      updateUI()
    }
    dampingSlider.addAction(dampingAction, for: .valueChanged)

    let playAction = UIAction { [weak self] _ in
      guard let self else {
        return
      }
      playButton.isEnabled = false

      let timingParameters = UISpringTimingParameters(
        mass: CGFloat(massSlider.value),
        stiffness: CGFloat(stiffnessSlider.value),
        damping: CGFloat(dampingSlider.value),
        initialVelocity: .zero
      )
      previewView.startAnimation(timingParameters, duration: 1) { [weak self] in
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

    scrollView.addSubview(springCurveControl)
    springCurveControl.snp.makeConstraints {
      $0.top.equalTo(scrollView.contentLayoutGuide)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(280)
      $0.height.equalTo(250)
    }

    let sliderStackView = UIStackView(axis: .vertical, spacing: 8) {
      massSlider
      stiffnessSlider
      dampingSlider
    }
    scrollView.addSubview(sliderStackView)
    sliderStackView.snp.makeConstraints {
      $0.top.equalTo(springCurveControl.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
    }

    scrollView.addSubview(previewView)
    previewView.snp.makeConstraints {
      $0.top.equalTo(sliderStackView.snp.bottom).offset(20)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.height.equalTo(previewView.snp.width).multipliedBy(0.2)
    }

    scrollView.addSubview(playButton)
    playButton.snp.makeConstraints {
      $0.top.equalTo(previewView.snp.bottom).offset(40)
      $0.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
      $0.bottom.equalTo(scrollView.contentLayoutGuide)
    }
  }
}

// MARK: - SpringTimingParametersViewController

#Preview {
  NavigationController(rootViewController: SpringTimingParametersViewController())
}
