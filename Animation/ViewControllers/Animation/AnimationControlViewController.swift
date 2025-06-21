//
//  AnimationControlViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

final class AnimationControlViewController: DetailViewController {
  override var menu: Menu? { .animationControl }
}

// MARK: - AnimationControlViewController Preview

#Preview {
  NavigationController(rootViewController: AnimationControlViewController())
}
