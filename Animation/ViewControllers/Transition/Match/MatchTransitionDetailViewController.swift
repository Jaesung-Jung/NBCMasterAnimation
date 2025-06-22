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
  private let transition: MatchTransition?

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
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Image Detail"
    view.backgroundColor = .black

    view.addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    let closeImage = UIImage(
      systemName: "xmark.circle.fill",
      withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 22, weight: .bold))
        .applying(UIImage.SymbolConfiguration(hierarchicalColor: .systemGray))
    )
    let closeAction = UIAction(image: closeImage) { [unowned self] _ in
      dismiss(animated: true)
    }
    let closeButton = UIButton(configuration: .plain(), primaryAction: closeAction).then {
      $0.configuration?.contentInsets = .zero
    }
    view.addSubview(closeButton)
    closeButton.snp.makeConstraints {
      $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
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
      url: URL(string: "https://images.unsplash.com/photo-1745933115134-9cd90e3efcc7")!
    ),
    sourceView: nil,
    sourceRect: .zero
  )
}
