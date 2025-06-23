//
//  AnimationControlViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then
import SnapKit

final class AnimationControlViewController: DetailViewController {
  override var menu: Menu? { .controlAnimation }

  private let animationView = UIView().then {
    $0.backgroundColor = .systemBlue
    $0.layer.cornerRadius = 4
  }

  private let startButton = UIButton(configuration: .filled()).then {
    $0.configuration?.title = "Start"
    $0.configuration?.image = UIImage(systemName: "play.fill")
    $0.configuration?.imagePadding = 8
    $0.configuration?.buttonSize = .large
    $0.tintColor = .systemBlue
  }

  private let pauseButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "Pause"
    $0.configuration?.image = UIImage(systemName: "pause.fill")
    $0.configuration?.imagePadding = 8
    $0.configuration?.buttonSize = .large
    $0.tintColor = .systemOrange
  }

  private let continueButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "Continue"
    $0.configuration?.image = UIImage(systemName: "play")
    $0.configuration?.imagePadding = 8
    $0.configuration?.buttonSize = .large
    $0.tintColor = .systemBlue
  }

  private let stopButton = UIButton(configuration: .tinted()).then {
    $0.configuration?.title = "Stop"
    $0.configuration?.image = UIImage(systemName: "stop.fill")
    $0.configuration?.imagePadding = 8
    $0.configuration?.buttonSize = .large
    $0.tintColor = .systemRed
  }

  private let progressSlider = ValueSlider().then {
    $0.title = "progress"
    $0.minimumValue = 0
    $0.step = 0.01
    $0.maximumValue = 1
    $0.fractionLength = 2...2
  }

  private var animationViewLeadingConstraints: Constraint?
  private var animationViewTrailingConstraints: Constraint?

  private var animator: UIViewPropertyAnimator?
  private var isReversed = false

  deinit {
    guard let animator else {
      return
    }
    switch animator.state {
    case .active:
      animator.stopAnimation(true)
    case .stopped:
      animator.finishAnimation(at: .current)
    default:
      break
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let containerView = UIView().then {
      $0.layer.borderColor = UIColor.systemGray.cgColor
      $0.layer.borderWidth = 1
      $0.layer.cornerRadius = 8
    }
    view.addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.height.equalTo(containerView.snp.width).multipliedBy(0.2)
      $0.centerY.equalToSuperview()
    }

    containerView.addSubview(animationView)
    animationView.snp.makeConstraints {
      $0.top.bottom.equalToSuperview().inset(4)
      $0.width.equalTo(animationView.snp.height)
    }


    let bottomView = UIStackView(axis: .vertical, spacing: 16) {
      progressSlider
      UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        startButton
        pauseButton
        continueButton
        stopButton
      }
    }
    view.addSubview(bottomView)
    bottomView.snp.makeConstraints {
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }

    animationView.snp.makeConstraints {
      animationViewLeadingConstraints = $0.leading.equalToSuperview().inset(4).constraint
    }

    animationView.snp.prepareConstraints {
      animationViewTrailingConstraints = $0.trailing.equalToSuperview().inset(4).constraint
    }

    setupControls()
    updateUI()
  }

  private func updateUI() {
    guard let animator else {
      progressSlider.isHidden = true
      startButton.isHidden = false
      pauseButton.isHidden = true
      continueButton.isHidden = true
      stopButton.isHidden = true
      return
    }
    switch animator.state {
    case .active where animator.isRunning: // running
      progressSlider.isHidden = true
      startButton.isHidden = true
      pauseButton.isHidden = false
      continueButton.isHidden = true
      stopButton.isHidden = false
    case .active: // paused
      progressSlider.value = Float(animator.fractionComplete)
      progressSlider.isHidden = false
      startButton.isHidden = true
      pauseButton.isHidden = true
      continueButton.isHidden = false
      stopButton.isHidden = false
    case .stopped: // stopped
      progressSlider.isHidden = true
      startButton.isHidden = false
      pauseButton.isHidden = true
      continueButton.isHidden = true
      stopButton.isHidden = true
    default: // inactive
      progressSlider.isHidden = true
      startButton.isHidden = false
      pauseButton.isHidden = true
      continueButton.isHidden = true
      stopButton.isHidden = true
    }
  }

  private func switchConstraints() {
    if animationViewLeadingConstraints?.isActive == true {
      animationViewLeadingConstraints?.isActive = false
      animationViewTrailingConstraints?.isActive = true
    } else {
      animationViewTrailingConstraints?.isActive = false
      animationViewLeadingConstraints?.isActive = true
    }
  }

  private func setupControls() {
    let progressAction = UIAction { [unowned self] _ in
      if let animator {
        animator.fractionComplete = CGFloat(progressSlider.value)
      }
    }
    progressSlider.addAction(progressAction, for: .valueChanged)

    let startAction = UIAction { [unowned self] _ in
      switchConstraints()
      let newAnimator = UIViewPropertyAnimator(duration: 2, curve: .easeInOut)
      newAnimator.addAnimations {
        self.view.layoutIfNeeded()
      }
      newAnimator.startAnimation()
      newAnimator.addCompletion { [weak self] _ in
        self?.animator = nil
        self?.updateUI()
      }
      if animator?.state == .stopped {
        animator?.finishAnimation(at: .start)
      }
      animator = newAnimator
      updateUI()
    }
    startButton.addAction(startAction, for: .primaryActionTriggered)

    let pauseAction = UIAction { [unowned self] _ in
      guard let animator else {
        return
      }
      animator.pauseAnimation()
      updateUI()
    }
    pauseButton.addAction(pauseAction, for: .primaryActionTriggered)

    let continueAction = UIAction { [unowned self] _ in
      guard let animator else {
        return
      }
      animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
      updateUI()
    }
    continueButton.addAction(continueAction, for: .primaryActionTriggered)

    let stopAction = UIAction { [unowned self] _ in
      guard let animator else {
        return
      }
      animator.stopAnimation(false)
      animator.finishAnimation(at: .end)
      updateUI()
    }
    stopButton.addAction(stopAction, for: .primaryActionTriggered)
  }
}

// MARK: - AnimationControlViewController Preview

#Preview {
  NavigationController(rootViewController: AnimationControlViewController())
}
