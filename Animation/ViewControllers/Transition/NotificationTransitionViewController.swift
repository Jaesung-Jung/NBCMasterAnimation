//
//  NotificationTransitionViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit

final class NotificationTransitionViewController: DetailViewController {
  override var menu: Menu? { .notificationTransition }
}

// MARK: - NotificationTransitionViewController Preview

#Preview {
  NavigationController(rootViewController: NotificationTransitionViewController())
}
