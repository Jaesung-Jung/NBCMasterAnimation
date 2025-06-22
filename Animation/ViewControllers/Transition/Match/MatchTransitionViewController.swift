//
//  MatchTransitionViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then
import SnapKit
import Kingfisher

final class MatchTransitionViewController: DetailViewController {
  @MainActor
  private var images: [RemoteImage] = []

  @MainActor
  private var currentPage = 1

  @MainActor
  private var hasNextPage = true

  @MainActor
  private var isLoading: Bool = false

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout()).then {
    $0.delegate = self
  }

  private lazy var dataSource = makeDataSource(collectionView)

  override var menu: Menu? { .matchTransition }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    Task {
      await fetchNextImages()
    }
  }
}

// MARK: - MatchTransitionViewController (UICollectionViewDelegate)

extension MatchTransitionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let image = images[indexPath.item]
    let cell = collectionView.cellForItem(at: indexPath)

    let offset = collectionView.contentOffset
    let contentInset = collectionView.adjustedContentInset
    let detailViewController = MatchTransitionDetailViewController(
      image: image,
      sourceView: cell,
      sourceRect: cell.map {
        CGRect(
          x: $0.frame.minX,
          y: $0.frame.minY + contentInset.top - (offset.y + contentInset.top),
          width: $0.frame.width,
          height: $0.frame.height
        )
      }
    )
    present(detailViewController, animated: true)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let visibleHeight = scrollView.frame.height - scrollView.contentInset.top - scrollView.contentInset.bottom
    let y = scrollView.contentOffset.y + scrollView.contentInset.top
    let threshold = scrollView.contentSize.height - visibleHeight
    if y > threshold {
      Task {
        await fetchNextImages()
      }
    }
  }
}

// MARK: - MatchTransitionViewController (Private)

extension MatchTransitionViewController {
  private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, RemoteImage> {
    let cellRegistration = UICollectionView.CellRegistration<ImageCell, RemoteImage> { cell, indexPath, item in
      cell.remoteImage = item
    }
    return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }

  private func makeCollectionViewLayout() -> UICollectionViewLayout {
    return UICollectionViewCompositionalLayout { _, environment in
      let insets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
      let spacing = CGFloat(10)
      let width = environment.container.effectiveContentSize.width - insets.leading - insets.trailing
      let size = (width - spacing) * 0.5
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
          subitems: [item, item]
        )
        .then {
          $0.interItemSpacing = .fixed(10)
        }
      return NSCollectionLayoutSection(group: group).then {
        $0.contentInsets = insets
        $0.interGroupSpacing = 10
      }
    }
  }

  private func fetchImages(page: Int) async throws -> [RemoteImage] {
    guard let url = URL(string: "https://unsplash.com/napi/topics/people/photos?page=\(page)&per_page=30") else {
      return []
    }
    let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
    return try JSONDecoder().decode([RemoteImage].self, from: data)
  }

  private func fetchNextImages() async {
    guard !isLoading, hasNextPage else {
      return
    }
    do {
      isLoading = true
      let newImages = try await fetchImages(page: currentPage)
      currentPage += 1
      hasNextPage = newImages.count >= 30
      images.append(contentsOf: newImages)
      updateImages(images)
      isLoading = false
    } catch {
      print(error)
    }
  }

  @MainActor
  private func updateImages(_ images: [RemoteImage]) {
    var snapshot = NSDiffableDataSourceSnapshot<Int, RemoteImage>()
    snapshot.appendSections([0])
    snapshot.appendItems(images, toSection: 0)
    dataSource.apply(snapshot)
  }
}

// MARK: - MatchTransitionViewController.ImageCell

extension MatchTransitionViewController {
  private class ImageCell: UICollectionViewCell {
    private var _task: Task<Void, Never>?

    private let imageView = UIImageView().then {
      $0.clipsToBounds = true
      $0.backgroundColor = .black
    }

    var remoteImage: RemoteImage? {
      didSet {
        imageView.kf.setImage(with: remoteImage?.url) { [imageView] in
          guard case .success(let result) = $0 else {
            return
          }
          if result.image.size.width > result.image.size.height {
            imageView.contentMode = .scaleAspectFit
          } else {
            imageView.contentMode = .scaleAspectFill
          }
        }
      }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
      contentView.addSubview(imageView)
      imageView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - MatchTransitionViewController Preview

#Preview {
  NavigationController(rootViewController: MatchTransitionViewController())
}
