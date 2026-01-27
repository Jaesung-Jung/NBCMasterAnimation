//
//  PushViewController.swift
//  Animation
//
//  Created by 정재성 on 1/27/26.
//

import UIKit
import Then

final class PushViewController: DetailViewController {
  private var blocks: [UIView] = []

  private let gravity = UIGravityBehavior(items: [])

  private let collision = UICollisionBehavior(items: []).then {
    $0.translatesReferenceBoundsIntoBoundary = true
  }

  private lazy var animator = UIDynamicAnimator(referenceView: view)

  override func viewDidLoad() {
    super.viewDidLoad()
    blocks.append(contentsOf: makeBlocks(in: view.bounds))

    for block in blocks {
      view.addSubview(block)
      gravity.addItem(block)
      collision.addItem(block)
    }

    animator.addBehavior(gravity)
    animator.addBehavior(collision)

    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
    view.addGestureRecognizer(tap)
  }
}

extension PushViewController {
  @objc private func handleTapGesture(_ sender: UITapGestureRecognizer) {
    let location = sender.location(in: view)

    for block in blocks {
      let dx = block.center.x - location.x
      let dy = block.center.y - location.y

      let distance = sqrt(dx * dx + dy * dy)
      if distance < 300 {
        let push = UIPushBehavior(items: [block], mode: .instantaneous)
        push.pushDirection = CGVector(dx: dx / 70, dy: dy / 70)
        push.active = true // 즉시 발동

        animator.addBehavior(push)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.animator.removeBehavior(push)
        }
      }
    }
  }

  private func makeBlocks(in bounds: CGRect) -> [UIView] {
    let rows = 5
    let columns = 5
    let size: CGFloat = 50

    let startX = (view.bounds.width - (CGFloat(columns) * size)) / 2
    let startY = view.bounds.height / 3

    var blocks: [UIView] = []
    blocks.reserveCapacity(rows * columns)
    for row in 0..<rows {
      for column in 0..<columns {
        let block = DynamicView(shape: .rectangle).then {
          $0.frame = CGRect(
            x: startX + CGFloat(column) * size,
            y: startY + CGFloat(row) * size,
            width: size,
            height: size
          )
        }
        blocks.append(block)
      }
    }
    return blocks
  }
}

// MARK: - PushViewController Preview

#Preview {
  NavigationController(rootViewController: PushViewController())
}
