//
//  LottiePreviewViewController.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit
import Then
import Lottie
import SnapKit

final class LottiePreviewViewController: UIViewController {
  private let animationView: LottieAnimationView

  private let slider = ValueSlider().then {
    $0.step = 0.01
    $0.minimumValue = 0
    $0.maximumValue = 1
    $0.fractionLength = 2...2
  }

  private let playButton = UIButton(configuration: .plain()).then {
    $0.configuration?.image = UIImage(systemName: "play.fill")
    $0.configuration?.contentInsets = .zero
  }

  private let pauseButton = UIButton(configuration: .plain()).then {
    $0.configuration?.image = UIImage(systemName: "pause.fill")
    $0.configuration?.contentInsets = .zero
  }

  private var displayLink: CADisplayLink?

  init(animation: LottieAnimation?) {
    self.animationView = LottieAnimationView(animation: animation).then {
      $0.loopMode = .loop
    }
    super.init(nibName: nil, bundle: nil)
    self.displayLink = CADisplayLink(target: self, selector: #selector(updateDisplay))
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Lottie Preview"
    view.backgroundColor = .systemBackground
    navigationItem.largeTitleDisplayMode = .never

    // Layout
    view.addSubview(animationView)
    animationView.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
    }
    displayLink?.add(to: .main, forMode: .default)

    let controlStackView = UIStackView(axis: .horizontal, spacing: 20) {
      playButton
      pauseButton
      slider
    }
    view.addSubview(controlStackView)
    controlStackView.snp.makeConstraints {
      $0.top.equalTo(animationView.snp.bottom).offset(20)
      $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }

    // Actions
    let sliderAction = UIAction { [unowned self] _ in
      animationView.currentProgress = CGFloat(slider.value)
    }
    slider.addAction(sliderAction, for: .valueChanged)

    let playAction = UIAction { [unowned self] _ in
      animationView.play()
    }
    playButton.addAction(playAction, for: .primaryActionTriggered)

    let pauseAction = UIAction { [unowned self] _ in
      animationView.pause()
    }
    pauseButton.addAction(pauseAction, for: .primaryActionTriggered)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animationView.play()
  }

  @objc func updateDisplay() {
    if animationView.isAnimationPlaying {
      playButton.isHidden = true
      pauseButton.isHidden = false
      slider.value = Float(animationView.realtimeAnimationProgress)
    } else {
      playButton.isHidden = false
      pauseButton.isHidden = true
    }
  }
}

// MARK: - LottiePreviewViewController Preview

#Preview {
  LottiePreviewViewController(animation: LottieAnimation.named(""))
}
