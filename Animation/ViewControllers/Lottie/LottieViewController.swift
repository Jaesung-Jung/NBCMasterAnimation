//
//  LottieViewController.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit
import Then
import Lottie
import SnapKit

final class LottieViewController: DetailViewController {
  override var menu: Menu? { .lottie }

  override func viewDidLoad() {
    super.viewDidLoad()
    let animationView = LottieAnimationView(name: "like")
    animationView.play()
    animationView.loopMode = .loop
  }
}
