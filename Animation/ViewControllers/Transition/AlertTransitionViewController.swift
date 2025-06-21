//
//  AlertTransitionViewController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then
import SnapKit

final class AlertTransitionViewController: DetailViewController {
  override var menu: Menu? { .notificationTransition }

  override func viewDidLoad() {
    super.viewDidLoad()
    let stackView = UIStackView(axis: .horizontal, spacing: 10) {
      UIButton(configuration: .filled(), primaryAction: UIAction(title: "Success Alert") { [unowned self] _ in
        let alertController = AlertController(style: .success, title: "Success", message: "Success Message")
        present(alertController, animated: true)
      })
      UIButton(configuration: .tinted(), primaryAction: UIAction(title: "Error Alert") { [unowned self] _ in
        let alertController = AlertController(style: .error, title: "Error", message: "Error Message")
        present(alertController, animated: true)
      })
    }
    view.addSubview(stackView)
    stackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
}

// MARK: - AlertTransitionViewController Preview

#Preview {
  NavigationController(rootViewController: AlertTransitionViewController())
}
