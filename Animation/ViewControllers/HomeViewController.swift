//
//  HomeViewController.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit
import Then
import SnapKit

final class HomeViewController: UIViewController {
  lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout()).then {
    $0.delegate = self
  }
  lazy var dataSource = makeDataSource(collectionView)

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "홈"

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    var snapshot = NSDiffableDataSourceSnapshot<Section, Menu>()
    snapshot.appendSections(Section.allCases)

    // Animation
    snapshot.appendItems(
      [
        .basicAnimation,
        .cubicParameters,
        .springParameters,
        .animationControl
      ],
      toSection: .animation
    )
    // Transition
    snapshot.appendItems(
      [
        .alertTransition,
        .seamlessTransition
      ],
      toSection: .transition
    )
    // Lottie
    snapshot.appendItems(
      [
        .lottie
      ],
      toSection: .lottie
    )

    dataSource.apply(snapshot)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let selectedIndexPaths = collectionView.indexPathsForSelectedItems, let transitionCoordinator else {
      return
    }
    transitionCoordinator.animate { [collectionView] _ in
      for indexPath in selectedIndexPaths {
        collectionView.deselectItem(at: indexPath, animated: true)
      }
    } completion: { [collectionView] context in
      if context.isCancelled {
        for indexPath in selectedIndexPaths {
          collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
      }
    }
  }
}

// MARK: - HomeViewController (Private)

extension HomeViewController {
  private func makeLayout() -> UICollectionViewLayout {
    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    configuration.headerMode = .supplementary
    return UICollectionViewCompositionalLayout.list(using: configuration)
  }

  private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Section, Menu> {
    // Cell
    let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Menu> { cell, indexPath, item in
      var configuration = cell.defaultContentConfiguration()
      configuration.image = item.image
      configuration.text = item.description
      cell.contentConfiguration = configuration
      cell.accessories = [.disclosureIndicator()]
    }
    let dataSource = UICollectionViewDiffableDataSource<Section, Menu>(collectionView: collectionView) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }

    // Supplementary
    let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, _, indexPath in
      guard let self, let section = self.dataSource.sectionIdentifier(for: indexPath.section) else {
        return
      }
      var configuration = headerView.defaultContentConfiguration()
      configuration.text = section.description
      headerView.contentConfiguration = configuration
    }
    dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
      collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
    }
    return dataSource
  }
}

// MARK: - HomeViewController (UICollectionViewDelegate)

extension HomeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let navigationController, let menu = dataSource.itemIdentifier(for: indexPath) else {
      return
    }
    let viewController = switch menu {
    case .basicAnimation:
      BasicAnimationViewController()
    case .cubicParameters:
      CubicTimingParametersViewController()
    case .springParameters:
      SpringTimingParametersViewController()
    case .animationControl:
      AnimationControlViewController()
    case .alertTransition:
      AlertTransitionViewController()
    case .seamlessTransition:
      SeamlessTransitionViewController()
    case .lottie:
      LottieViewController()
    }
    navigationController.pushViewController(viewController, animated: true)
  }
}

// MARK: - HomeViewController.Section

extension HomeViewController {
  enum Section: Int, CustomStringConvertible, CaseIterable {
    case animation
    case transition
    case lottie

    var description: String {
      switch self {
      case .animation:
        return "Animation"
      case .transition:
        return "Transition"
      case .lottie:
        return "Lottie"
      }
    }
  }
}

// MARK: - HomeViewController.Menu

extension HomeViewController {
  enum Menu: CustomStringConvertible {
    case basicAnimation
    case cubicParameters
    case springParameters
    case animationControl

    case alertTransition
    case seamlessTransition

    case lottie

    var image: UIImage {
      switch self {
      case .basicAnimation:
        UIImage(
          systemName: "point.bottomleft.filled.forward.to.point.topright.scurvepath",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
        )!
      case .cubicParameters:
        UIImage(
          systemName: "beziercurve",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
        )!
      case .springParameters:
        UIImage(
          systemName: "waveform.path.ecg",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
        )!
      case .animationControl:
        UIImage(
          systemName: "slider.horizontal.3",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemBlue)
        )!
      case .alertTransition:
        UIImage(
          systemName: "inset.filled.tophalf.bottomleft.bottomright.rectangle",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
        )!
      case .seamlessTransition:
        UIImage(
          systemName: "rectangle.on.rectangle",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemGreen)
        )!
      case .lottie:
        UIImage(
          systemName: "sparkles.square.filled.on.square",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: .systemMint)
        )!
      }
    }

    var description: String {
      switch self {
      case .basicAnimation:
        return "Basic Animation"
      case .cubicParameters:
        return "Cubic Timing Parameters"
      case .springParameters:
        return "Spring Timing Parameters"
      case .animationControl:
        return "Animation Control"
      case .alertTransition:
        return "Alert Transition"
      case .seamlessTransition:
        return "Seamless Transition"
      case .lottie:
        return "Lottie Preview"
      }
    }
  }
}

// MARK: - HomeViewController Preview

#Preview {
  NavigationController(rootViewController: HomeViewController())
}
