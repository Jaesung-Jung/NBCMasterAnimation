//
//  SnapViewController.swift
//  Animation
//
//  Created by 정재성 on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class SnapViewController: DetailViewController {
  private let itemView = DynamicView(shape: .ellipse).then {
    $0.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    $0.shadowOpacity = 0.3
  }

  private var snapBehavior: UISnapBehavior?

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

    itemView.center = view.center
    view.addSubview(itemView)

    let collisionBehavior = UICollisionBehavior(items: [itemView]).then {
      $0.translatesReferenceBoundsIntoBoundary = true
    }
    animator.addBehavior(collisionBehavior)

    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    view.addGestureRecognizer(tap)
  }

  @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
    let location = sender.location(in: view)
    if let snapBehavior {
      animator.removeBehavior(snapBehavior)
    }

    let newSnapBehavior = UISnapBehavior(item: itemView, snapTo: location).then {
      $0.damping = 0.5
    }
    animator.addBehavior(newSnapBehavior)

    snapBehavior = newSnapBehavior
  }
}

// MARK: - SnapViewController Preview

#Preview {
  NavigationController(rootViewController: SnapViewController())
}
