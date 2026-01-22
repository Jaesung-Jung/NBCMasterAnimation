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

final class MatchTransitionDetailViewController: UIViewController, UINavigationBarDelegate {
  private let transition: MatchTransition?

  private let navigationBar = UINavigationBar()

  private let imageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }

  init(image: RemoteImage, sourceView: UIView?, sourceRect: CGRect?) {
    if let sourceView, let sourceRect {
      self.transition = MatchTransition(sourceView: sourceView, sourceRect: sourceRect)
    } else {
      self.transition = nil
    }
    super.init(nibName: nil, bundle: nil)
    imageView.kf.setImage(with: image.url)
    if let transition {
      self.transitioningDelegate = transition
      self.modalPresentationStyle = .custom
    }

    navigationBar.items = [navigationItem]
    navigationBar.delegate = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    view.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    view.addSubview(navigationBar)
    navigationBar.snp.makeConstraints {
      $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
    }

    let closeAction = UIAction { [unowned self] _ in
      dismiss(animated: true)
    }
    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: closeAction)
  }

  func position(for bar: any UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: - MatchTransitionDetailViewController Preview

#Preview {
  MatchTransitionDetailViewController(
    image: RemoteImage(
      id: UUID().uuidString,
      size: .zero,
      likes: 0,
      url: URL(string: "https://images.unsplash.com/photo-1745933115134-9cd90e3efcc7")!
    ),
    sourceView: nil,
    sourceRect: .zero
  )
}
