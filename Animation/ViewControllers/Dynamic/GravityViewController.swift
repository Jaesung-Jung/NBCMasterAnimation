//
//  GravityViewController.swift
//  Animation
//
//  Created by 정재성 on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class GravityViewController: DetailViewController {
  private let sun = DynamicView(shape: .ellipse).then {
    $0.color = .systemYellow
    $0.shadowColor = .orange
    $0.shadowRadius = 50
    $0.shadowOpacity = 1
  }

  private var satellites: [UIView] = []

  private let collision = UICollisionBehavior(items: []).then {
    $0.translatesReferenceBoundsIntoBoundary = true
  }

  private let itemBehavior = UIDynamicItemBehavior(items: []).then {
    $0.friction = 0.0
    $0.elasticity = 0.0
    $0.resistance = 0.1
  }

  private lazy var gravityField = UIFieldBehavior.radialGravityField(position: view.center).then {
    $0.region = UIRegion(radius: 500)
    $0.strength = 1.0
    $0.falloff = 2.0
    $0.minimumRadius = 40
  }

  private lazy var animator = UIDynamicAnimator(referenceView: view)

  override func viewDidLoad() {
    super.viewDidLoad()
    let infoLabel = ShimmerEffectLabel(text: "노란색 원을\n드래그 해보세요.").then {
      $0.font = .systemFont(ofSize: 20, weight: .bold)
    }
    view.addSubview(infoLabel)
    infoLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.centerX.equalToSuperview()
    }

    sun.frame = CGRect(
      x: view.frame.midX - 40,
      y: view.frame.midY - 40,
      width: 80,
      height: 80
    )
    view.addSubview(sun)

    satellites.append(contentsOf: makeSatellites(count: 20))

    for satellite in satellites {
      view.addSubview(satellite)
      collision.addItem(satellite)
      itemBehavior.addItem(satellite)
      gravityField.addItem(satellite)
    }

    animator.addBehavior(itemBehavior)
    animator.addBehavior(collision)
    animator.addBehavior(gravityField)

    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    sun.addGestureRecognizer(panGesture)
  }
}

extension GravityViewController {
  @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    let translation = sender.translation(in: view)
    sender.setTranslation(.zero, in: view)

    sun.center = CGPoint(
      x: sun.center.x + translation.x,
      y: sun.center.y + translation.y
    )

    gravityField.position = sun.center
  }

  private func makeSatellites(count: Int) -> [UIView] {
    repeatElement((), count: count).map {
      let size = CGFloat.random(in: 15...30)
      return DynamicView(shape: .ellipse).then {
        $0.frame = CGRect(
          x: .random(in: 0...(view.bounds.maxX - size)),
          y: .random(in: 0...(view.bounds.maxY - size)),
          width: size,
          height: size
        )
        $0.isUserInteractionEnabled = false
        $0.alpha = 0.5
      }
    }
  }
}

// MARK: - GravityViewController Preview

#Preview {
  NavigationController(rootViewController: GravityViewController())
}
