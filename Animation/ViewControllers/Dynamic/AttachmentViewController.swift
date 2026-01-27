//
//  AttachmentViewController.swift
//  Animation
//
//  Created by 정재성 on 1/27/26.
//

import UIKit
import Then

final class AttachmentViewController: DetailViewController {
  private let itemView = DynamicView(shape: .ellipse)

  private let anchorView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10)).then {
    $0.backgroundColor = .systemRed
    $0.layer.cornerRadius = 5
    $0.isHidden = true
  }

  private let lineLayer = CAShapeLayer().then {
    $0.strokeColor = UIColor.systemGray.cgColor
    $0.lineWidth = 2.0
    $0.lineDashPattern = [4, 4] // 점선 효과
  }

  private var attachmentBehavior: UIAttachmentBehavior?

  private lazy var animator = UIDynamicAnimator(referenceView: view)

  override func viewDidLoad() {
    super.viewDidLoad()
    view.layer.addSublayer(lineLayer)
    view.addSubview(itemView)
    view.addSubview(anchorView)

    itemView.frame = CGRect(
      x: view.center.x - 20,
      y: view.center.y - 20,
      width: 50,
      height: 50
    )

    let itemBehavior = UIDynamicItemBehavior(items: [itemView]).then {
      $0.elasticity = 1
      $0.friction = 3
      $0.resistance = 0.5
      $0.angularResistance = 1
    }
    animator.addBehavior(itemBehavior)

    let collisionBehavior = UICollisionBehavior(items: [itemView]).then {
      $0.translatesReferenceBoundsIntoBoundary = true
    }
    animator.addBehavior(collisionBehavior)

    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    view.addGestureRecognizer(panGesture)
  }
}

extension AttachmentViewController {
  @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    let location = sender.location(in: sender.view)

    switch sender.state {
    case .began:
      anchorView.center = location
      anchorView.isHidden = false

      let newAttachmentBehavior = UIAttachmentBehavior(item: itemView, attachedToAnchor: location).then {
        $0.length = 5         // 줄의 길이
        $0.damping = 0.5      // 0.0 ~ 1.0
        $0.frequency = 2.0    // 진동수
      }
      newAttachmentBehavior.action = { [weak self] in
        guard let self, let attachmentBehavior else {
          return
        }
        let path = UIBezierPath()
        path.move(to: attachmentBehavior.anchorPoint)
        path.addLine(to: itemView.center)
        lineLayer.path = path.cgPath
      }
      animator.addBehavior(newAttachmentBehavior)
      attachmentBehavior = newAttachmentBehavior

    case .changed:
      // 드래그 중: 앵커(손가락) 위치 업데이트
      attachmentBehavior?.anchorPoint = location
      anchorView.center = location

    case .ended, .cancelled:
      // 드래그 끝: 줄 끊기
      if let attachmentBehavior {
        animator.removeBehavior(attachmentBehavior)
      }
      anchorView.isHidden = true
      lineLayer.path = nil

    default:
      break
    }
  }
}

// MARK: - AttachmentViewController Preview

#Preview {
  NavigationController(rootViewController: AttachmentViewController())
}
