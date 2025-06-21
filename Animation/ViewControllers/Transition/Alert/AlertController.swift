//
//  AlertController.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then
import SnapKit

final class AlertController: UIViewController {
  private let contentView: ContentView
  private let transition = AlertTransition()

  @inlinable var style: Style { contentView.style }
  @inlinable var notificationTitle: String { contentView.title }
  @inlinable var notificationMessage: String { contentView.message }

  init(style: Style, title: String, message: String, actions: Set<Action> = [.cancel, .confirm]) {
    self.contentView = ContentView(style: style, title: title, message: message, actions: actions)
    super.init(nibName: nil, bundle: nil)
    self.transitioningDelegate = transition
    self.modalPresentationStyle = .custom
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.equalTo(280)
    }

    contentView.actionHandler = { [unowned self] _ in
      dismiss(animated: true)
    }
  }
}

// MARK: - AlertController.Style

extension AlertController {
  enum Style {
    case success
    case error

    var icon: UIImage? {
      switch self {
      case .success:
        UIImage(
          systemName: "checkmark.circle.fill",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: color)
        )
      case .error:
        UIImage(
          systemName: "exclamationmark.circle.fill",
          withConfiguration: UIImage.SymbolConfiguration(hierarchicalColor: color)
        )
      }
    }

    var color: UIColor {
      switch self {
      case .success: .systemGreen
      case .error: .systemRed
      }
    }
  }
}

// MARK: - AlertController.Action

extension AlertController {
  enum Action {
    case confirm
    case cancel
  }
}

// MARK: - AlertController.ContentView

extension AlertController {
  private class ContentView: UIView {
    let style: Style
    let title: String
    let message: String

    var actionHandler: ((Action) -> Void)?

    let backgroundView = UIView().then {
      $0.backgroundColor = .systemBackground
      $0.layer.shadowColor = UIColor.black.cgColor
      $0.layer.shadowOpacity = 0.15
      $0.layer.shadowOffset = CGSize(width: 0, height: 1)
      $0.layer.shouldRasterize = true
      $0.layer.shadowRadius = 20
      $0.layer.cornerRadius = 26
      $0.layer.cornerCurve = .continuous
    }

    init(style: Style, title: String, message: String, actions: Set<Action>) {
      self.style = style
      self.title = title
      self.message = message
      super.init(frame: .zero)
      tintColor = style.color

      // Background

      addSubview(backgroundView)
      backgroundView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }

      let gradientView = GradientView(
        colors: [style.color.withAlphaComponent(0.1), .white.withAlphaComponent(0)],
        startPoint: CGPoint(x: 0, y: 0),
        endPoint: CGPoint(x: 0, y: 1)
      ).then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 26
      }
      backgroundView.addSubview(gradientView)
      gradientView.snp.makeConstraints {
        $0.directionalEdges.equalToSuperview()
      }

      // Contents

      insetsLayoutMarginsFromSafeArea = false
      directionalLayoutMargins = NSDirectionalEdgeInsets(
        top: 20,
        leading: 20,
        bottom: 20,
        trailing: 20
      )

      let iconImageView = UIImageView(image: style.icon).then {
        $0.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
          font: .systemFont(ofSize: 17, weight: .bold)
        )
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
      }
      addSubview(iconImageView)
      iconImageView.snp.makeConstraints {
        $0.top.leading.equalTo(directionalLayoutMargins)
      }

      let titleLabel = Label(title).then {
        $0.font = .systemFont(ofSize: 17, weight: .heavy)
        $0.setContentHuggingPriority(.defaultHigh, for: .vertical)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        $0.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
      }
      addSubview(titleLabel)
      titleLabel.snp.makeConstraints {
        $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
        $0.trailing.equalTo(directionalLayoutMargins)
        $0.centerY.equalTo(iconImageView)
      }

      let messageLabel = Label(message).then {
        $0.font = .systemFont(ofSize: 15, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.numberOfLines = 0
      }
      addSubview(messageLabel)
      messageLabel.snp.makeConstraints {
        $0.top.equalTo(iconImageView.snp.bottom).offset(16)
        $0.leading.trailing.equalTo(directionalLayoutMargins)
      }

      let buttonStackView = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 10) {
        if actions.contains(.cancel) {
          CancelButton { [unowned self] in actionHandler?(.cancel) }
        }
        if actions.contains(.confirm) {
          ConfirmButton { [unowned self] in actionHandler?(.confirm) }
        }
      }
      addSubview(buttonStackView)
      buttonStackView.snp.makeConstraints {
        $0.top.equalTo(messageLabel.snp.bottom).offset(32)
        $0.leading.trailing.bottom.equalTo(directionalLayoutMargins)
      }
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      backgroundView.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 32).cgPath
    }
  }
}

// MARK: - AlertController.CancelButton

extension AlertController {
  private class CancelButton: UIButton {
    init(action: @escaping () -> Void) {
      super.init(frame: .zero)
      var configuration = Configuration.gray()
      configuration.title = "Cancel"
      configuration.cornerStyle = .capsule
      configuration.baseForegroundColor = .systemGray
      configuration.baseBackgroundColor = .systemGray6
      self.configuration = configuration
      addAction(UIAction { _ in action() }, for: .primaryActionTriggered)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - AlertController.ConfirmButton

extension AlertController {
  private class ConfirmButton: UIButton {
    init(action: @escaping () -> Void) {
      super.init(frame: .zero)
      var configuration = Configuration.tinted()
      configuration.title = "Confirm"
      configuration.cornerStyle = .capsule
      self.configuration = configuration
      addAction(UIAction { _ in action() }, for: .primaryActionTriggered)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
  }
}

// MARK: - NotificationController Preview

#Preview {
  AlertController(style: .success, title: "Success", message: "Notification Message")
}
