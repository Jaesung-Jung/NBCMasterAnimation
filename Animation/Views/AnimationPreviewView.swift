//
//  AnimationPreviewView.swift
//  Animation
//
//  Created by 정재성 on 6/20/25.
//

import UIKit
import Then
import SnapKit

final class AnimationPreviewView: UIView {
  private let prepareAnimations: (UIView, CGRect) -> Void
  private let animations: (UIView, CGRect, Bool) -> Void

  private let containerView = UIView()
  private var pendingAction: (() -> Void)?

  private let itemView = UIView().then {
    $0.backgroundColor = .systemRandomColor
  }

  private var animator: UIViewPropertyAnimator?

  init(prepareAnimations: @escaping (UIView, CGRect) -> Void = { _, _ in }, animations: @escaping (UIView, CGRect, Bool) -> Void) {
    self.prepareAnimations = prepareAnimations
    self.animations = animations
    super.init(frame: .zero)
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.systemGray3.cgColor
    self.layer.cornerRadius = 8
    addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview().inset(10)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if itemView.superview == nil {
      let bounds = containerView.bounds
      let size = min(bounds.width, bounds.height)
      itemView.frame = CGRect(x: bounds.midX - size * 0.5, y: bounds.midY - size * 0.5, width: size, height: size)
      containerView.addSubview(itemView)
      prepareAnimations(itemView, bounds)

      if let pendingAction {
        pendingAction()
      }
      pendingAction = nil
    }
  }

  func startAnimation<Curve: UITimingCurveProvider>(_ timingParameters: Curve, duration: TimeInterval = 1, repeat mode: RepeatMode = .once, completion: (() -> Void)? = nil) {
    if itemView.superview == nil {
      pendingAction = {
        self.runAnimator(timingParameters, duration: duration, repeat: mode, isReversed: false, completion: completion)
      }
    } else {
      runAnimator(timingParameters, duration: duration, repeat: mode, isReversed: false, completion: completion)
    }
  }

  func pauseAnimation() {
    animator?.pauseAnimation()
  }

  func stopAnimation() {
    animator?.stopAnimation(true)
  }

  private func runAnimator<Curve: UITimingCurveProvider>(_ timingParameters: Curve, duration: TimeInterval, repeat mode: RepeatMode, isReversed: Bool, completion: (() -> Void)?) {
    if let animator {
      animator.stopAnimation(true)
    }
    animator = UIViewPropertyAnimator(duration: duration, timingParameters: timingParameters)
    animator?.addAnimations {
      self.animations(self.itemView, self.containerView.bounds, isReversed)
    }
    if mode == .infinity {
      animator?.addCompletion { [weak self] position in
        if position == .end {
          self?.runAnimator(timingParameters, duration: duration, repeat: mode, isReversed: !isReversed, completion: nil)
        }
      }
    } else {
      animator?.addCompletion { _ in
        completion?()
      }
    }
    animator?.startAnimation()
  }
}

// MARK: - AnimationPreviewView.RepeatMode

extension AnimationPreviewView {
  enum RepeatMode {
    case once
    case infinity
  }
}

// MARK: - AnimationPreviewView Preview

#Preview {
  AnimationPreviewView { item, _, isReversed in
    item.transform = isReversed ? .identity : CGAffineTransform(scaleX: 0.5, y: 0.5)
  }
  .then {
    $0.snp.makeConstraints {
      $0.width.equalTo(300)
      $0.height.equalTo(100)
    }
    $0.startAnimation(UISpringTimingParameters(dampingRatio: 0.25), repeat: .infinity)
  }
}
