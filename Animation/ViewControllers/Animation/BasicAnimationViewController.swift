//
//  BasicAnimationViewController.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit
import Then
import SnapKit

final class BasicAnimationViewController: DetailViewController {
  override var menu: Menu? { .basicAnimation }

  override func viewDidLoad() {
    super.viewDidLoad()
    let scrollView = UIScrollView()
    view.addSubview(scrollView)
    scrollView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
      $0.width.equalTo(scrollView.contentLayoutGuide)
    }

    let animationStackView = UIStackView(axis: .vertical, spacing: 20) {
      AnimationItem("translation") {
        $0.frame.origin.x = $1.minX
      } animations: { item, rect, isReversed in
        if isReversed {
          item.transform = .identity
        } else {
          item.transform = CGAffineTransform(translationX: rect.maxX - item.frame.width, y: 0)
        }
      }

      AnimationItem("rotate") { item, rect, isReversed in
        if isReversed {
          item.transform = .identity
        } else {
          item.transform = CGAffineTransform(rotationAngle: .pi)
        }
      }

      AnimationItem("scale") { item, rect, isReversed in
        if isReversed {
          item.transform = .identity
        } else {
          item.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
      }

      AnimationItem("cornerRadius") { item, rect, isReversed in
        if isReversed {
          item.layer.cornerRadius = 0
        } else {
          item.layer.cornerRadius = rect.height * 0.5
        }
      }

      AnimationItem("color") { item, rect, isReversed in
        item.backgroundColor = .systemRandomColor
      }

      AnimationItem("alpha") { item, rect, isReversed in
        item.alpha = isReversed ? 1 : 0.2
      }

      AnimationItem("border") { item, _ in
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

// MARK: - BasicAnimationViewController.AnimationItem

extension BasicAnimationViewController {
  final class AnimationItem: UIView {
    private let previewView: AnimationPreviewView

    init(_ title: String, prepare: @escaping (UIView, CGRect) -> Void = { _, _ in }, animations: @escaping (UIView, CGRect, Bool) -> Void) {
      self.previewView = AnimationPreviewView(prepareAnimations: prepare, animations: animations)
      super.init(frame: .zero)
      let titleLabel = Label().then {
        $0.text = title
        $0.textColor = .secondaryLabel
        $0.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
      }
      addSubview(titleLabel)
      titleLabel.snp.makeConstraints {
        $0.top.leading.trailing.equalToSuperview()
      }
      addSubview(previewView)
      previewView.snp.makeConstraints {
        $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        $0.leading.trailing.bottom.equalToSuperview()
        $0.height.equalTo(100)
      }

      previewView.startAnimation(UICubicTimingParameters(animationCurve: .easeInOut), repeat: .infinity)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - BasicAnimationViewController Preview

#Preview {
  NavigationController(rootViewController: BasicAnimationViewController())
}
