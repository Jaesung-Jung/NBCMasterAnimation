//
//  MatchTransition.swift
//  Animation
//
//  Created by 정재성 on 6/22/25.
//

import UIKit

final class MatchTransition: NSObject, UIViewControllerTransitioningDelegate {
  let sourceView: UIView

  init(sourceView: UIView) {
    self.sourceView = sourceView
  }
}
