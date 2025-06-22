//
//  MatchTransitionDetailViewController.swift
//  Animation
//
//  Created by 정재성 on 6/22/25.
//

import UIKit
import Then
import SnapKit
import Kingfisher

final class MatchTransitionDetailViewController: UIViewController {
  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }

  init(image: RemoteImage) {
    super.init(nibName: nil, bundle: nil)
    print("\(image.id) - \(image.hashValue)")
    imageView.kf.setImage(with: image.url)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Image Detail"
    view.backgroundColor = .systemBackground

    view.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

// MARK: - MatchTransitionDetailViewController Preview

#Preview {
  MatchTransitionDetailViewController(
    image: RemoteImage(
      id: UUID().uuidString,
      size: .zero,
      likes: 0,
      url: URL(string: "https://images.unsplash.com/photo-1745933115134-9cd90e3efcc7?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3wxMjA3fDB8MXxhbGx8MzB8fHx8fHx8fDE3NTA1MTU0NDB8&ixlib=rb-4.1.0&q=80&w=1080")!
    )
  )
}
