//
//  LottieListViewController.swift
//  Animation
//
//  Created by 정재성 on 6/23/25.
//

import UIKit
import Then
import SnapKit
import Lottie

final class LottieListViewController: DetailViewController {
  lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
    $0.delegate = self
  }

  lazy var dataSource = makeDataSource(collectionView)

  override var menu: Menu? { .lottie }

  override func viewDidLoad() {
    super.viewDidLoad()
    let lottieFiles: [URL]
    if let resourceURL = Bundle.main.resourceURL?.appending(path: "LottieAnimations") {
      lottieFiles = (try? FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)) ?? []
    } else {
      lottieFiles = []
    }

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    var snapshot = NSDiffableDataSourceSnapshot<Int, URL>()
    snapshot.appendSections([0])
    snapshot.appendItems(lottieFiles, toSection: 0)
    dataSource.apply(snapshot)
  }
}

// MARK: - LottieListViewController (UICollectionViewDelegate)

extension LottieListViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let url = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    guard let data = try? Data(contentsOf: url), let animation = try? LottieAnimation.from(data: data) else {
      return
    }
    let previewViewController = LottiePreviewViewController(animation: animation)
    navigationController?.pushViewController(previewViewController, animated: true)
  }
}

// MARK: - LottieListViewController.LottieItemCell

extension LottieListViewController {
  private class LottieItemCell: UICollectionViewCell {
    let animationView = LottieAnimationView().then {
      $0.contentMode = .scaleAspectFill
      $0.loopMode = .loop
    }

    var animationURL: URL? {
      didSet {
        animationView.stop()
        if let animationURL, let data = try? Data(contentsOf: animationURL) {
          animationView.animation = try? LottieAnimation.from(data: data)
          animationView.play()
        }
      }
    }

    override var isHighlighted: Bool {
      didSet {
        let alpha = isHighlighted ? 0.25 : 1
        UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
          self.contentView.alpha = alpha
        }
        .startAnimation()
      }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
      backgroundColor = .systemGray6
      contentView.clipsToBounds = true
      contentView.addSubview(animationView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      animationView.frame = contentView.bounds
    }
  }
}

// MARK: - LottieListViewController (Private)

extension LottieListViewController {
  private func makeLayout() -> UICollectionViewLayout {
    UICollectionViewCompositionalLayout { _, environment in
      let insets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
      let spacing = CGFloat(10)
      let width = environment.container.effectiveContentSize.width - insets.leading - insets.trailing
      let size = (width - spacing) * 0.33
      let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .absolute(size),
          heightDimension: .absolute(size)
        )
      )
      let group = NSCollectionLayoutGroup
        .horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(size)
          ),
          subitems: [item, item, item]
        )
        .then {
          $0.interItemSpacing = .flexible(0)
        }
      return NSCollectionLayoutSection(group: group).then {
        $0.contentInsets = insets
        $0.interGroupSpacing = 10
      }
    }
  }

  private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, URL> {
    let cellRegistration = UICollectionView.CellRegistration<LottieItemCell, URL> { cell, indexPath, url in
      cell.animationURL = url
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}

// MARK: - LottieListViewController Preview

#Preview {
  NavigationController(rootViewController: LottieListViewController())
}
