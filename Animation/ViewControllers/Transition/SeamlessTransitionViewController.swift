//
//  SeamlessTransitionViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

final class SeamlessTransitionViewController: DetailViewController {
  override var menu: Menu? { .seamlessTransition }
}

// MARK: - SeamlessTransitionViewController Preview

#Preview {
  NavigationController(rootViewController: SeamlessTransitionViewController())
}
