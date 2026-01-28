//
//  CollisionViewController.swift
//  Animation
//
//  Created by 정재성 on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class CollisionViewController: DetailViewController {
  private let barrierView = UIView().then {
    $0.backgroundColor = .secondaryLabel
    $0.layer.cornerRadius = 5
  }

  private let gravityBehavior = UIGravityBehavior(items: [])

  private let collisionBehavior = UICollisionBehavior(items: []).then {
    $0.translatesReferenceBoundsIntoBoundary = true
  }

  private let itemBehavior = UIDynamicItemBehavior(items: []).then {
    $0.elasticity = 0.7
  }

  private lazy var animator = UIDynamicAnimator(referenceView: view)

  override func viewDidLoad() {
    super.viewDidLoad()
    let infoLabel = ShimmerEffectLabel(text: "화면을 터치\n해보세요.").then {
      $0.font = .systemFont(ofSize: 20, weight: .bold)
    }
    view.addSubview(infoLabel)
    infoLabel.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).inset(20)
      $0.centerX.equalToSuperview()
    }

    view.addSubview(barrierView)

    animator.addBehavior(gravityBehavior)
    animator.addBehavior(collisionBehavior)
    animator.addBehavior(itemBehavior)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    view.addGestureRecognizer(tapGesture)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    barrierView.frame = CGRect(
      x: view.bounds.midX - 100,
      y: view.bounds.maxY - 150,
      width: 200,
      height: 10
    )

    let identifier = NSString(string: "barrier")
    if collisionBehavior.boundary(withIdentifier: identifier) != nil {
      collisionBehavior.removeBoundary(withIdentifier: identifier)
    }
    let path = UIBezierPath(rect: barrierView.frame)
    collisionBehavior.addBoundary(withIdentifier: identifier, for: path)
  }
}

extension CollisionViewController {
  @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
    let location = sender.location(in: view)
    let item = DynamicView(shape: .ellipse).then {
      $0.frame = CGRect(
        x: location.x,
        y: location.y,
        width: 50,
        height: 50
      )
    }
    view.addSubview(item)

    gravityBehavior.addItem(item)
    collisionBehavior.addItem(item)
    itemBehavior.addItem(item)
  }
}

// MARK: - CollisionViewController Preview

#Preview {
  NavigationController(rootViewController: CollisionViewController())
}
