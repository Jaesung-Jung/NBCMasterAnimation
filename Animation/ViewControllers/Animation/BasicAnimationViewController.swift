//
//  BasicAnimationViewController.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit
import Then
import SnapKit

final class BasicAnimationViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Basic Animation"
    view.backgroundColor = .systemBackground

    let scrollView = UIScrollView()
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
      $0.width.equalTo(scrollView.contentLayoutGuide)
    }

    let animationStackView = UIStackView(axis: .vertical, spacing: 20) {
      AnimationPreviewView(title: "translation") {
        $0.frame.origin.x = $1.minX
      } animations: { item, rect, isReversed in
        if isReversed {
          item.transform = .identity
        } else {
          item.transform = CGAffineTransform(translationX: rect.width - item.frame.width, y: 0)
        }
      }

      AnimationPreviewView(title: "rotate") { item, rect, isReversed in
        if isReversed {
          item.transform = .identity
        } else {
          item.transform = CGAffineTransform(rotationAngle: .pi)
        }
      }

      AnimationPreviewView(title: "scale") {
        $0.layer.cornerRadius = $1.height * 0.5
      } animations: { item, rect, isReversed in
        if isReversed {
          item.transform = .identity
        } else {
          item.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
      }

      AnimationPreviewView(title: "cornerRadius") { item, rect, isReversed in
        if isReversed {
          item.layer.cornerRadius = 0
        } else {
          item.layer.cornerRadius = rect.height * 0.5
        }
      }

      AnimationPreviewView(title: "color") { item, rect, isReversed in
        item.backgroundColor = .systemRandomColor
      }

      AnimationPreviewView(title: "alpha") { item, rect, isReversed in
        item.alpha = isReversed ? 1 : 0.2
      }

      AnimationPreviewView(title: "border") { item, _ in
        item.layer.cornerRadius = 8
        item.layer.borderColor = UIColor.systemGray.cgColor
      } animations: { item, rect, isReversed in
        item.layer.borderWidth = isReversed ? 0 : 8
      }
    }
    scrollView.addSubview(animationStackView)
    animationStackView.snp.makeConstraints {
      $0.top.bottom.equalTo(scrollView.contentLayoutGuide)
      $0.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(20)
    }
  }
}

// MARK: - BasicAnimationViewController.AnimationPreviewView

extension BasicAnimationViewController {
  final class AnimationPreviewView: UIView {
    private let containerView = UIView().then {
      $0.backgroundColor = .systemGray6
      $0.layer.cornerRadius = 8
    }
    private let itemView = UIView().then {
      $0.backgroundColor = .systemRandomColor
    }

    private let prepare: ((UIView, CGRect) -> Void)?
    private let animations: (UIView, CGRect, Bool) -> Void

    private var animator: UIViewPropertyAnimator?
    private var isReversed = false

    init(title: String, prepare: ((UIView, CGRect) -> Void)? = nil, animations: @escaping (UIView, CGRect, Bool) -> Void) {
      self.prepare = prepare
      self.animations = animations
      super.init(frame: .zero)
      let titleLabel = UILabel().then {
        $0.text = title
        $0.textColor = .secondaryLabel
        $0.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
      }
      addSubview(titleLabel)
      titleLabel.snp.makeConstraints {
        $0.top.leading.trailing.equalToSuperview()
      }
      addSubview(containerView)
      containerView.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        $0.leading.trailing.bottom.equalToSuperview()
        $0.height.equalTo(80)
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      let rect = containerView.bounds.insetBy(dx: 10, dy: 10)
      if itemView.superview == nil {
        containerView.addSubview(itemView)

        let size = min(rect.width, rect.height)
        itemView.frame = CGRect(x: rect.midX - size * 0.5, y: rect.midY - size * 0.5, width: size, height: size)
        prepare?(itemView, rect)
      }
      startAnimationIfNeeded(rect: rect)
    }

    private func startAnimationIfNeeded(rect: CGRect) {
      guard animator == nil else {
        return
      }
      animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut)
      animator?.addAnimations { [weak self] in
        guard let self else {
          return
        }
        animations(itemView, rect, isReversed)
      }
      animator?.addCompletion { [weak self] _ in
        self?.isReversed.toggle()
        self?.animator = nil
        self?.startAnimationIfNeeded(rect: rect)
      }
      animator?.startAnimation()
    }
  }
}

// MARK: - BasicAnimationViewController Preview

#Preview {
  NavigationController(rootViewController: BasicAnimationViewController())
}
