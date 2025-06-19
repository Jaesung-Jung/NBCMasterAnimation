//
//  UIButton+Extension.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit

extension UIButton {
  convenience init(configuration: UIButton.Configuration, action: @escaping () -> Void) {
    self.init(configuration: configuration, primaryAction: UIAction { _ in action() })
  }
}

extension UIButton.Configuration {
  static func filled(title: String) -> UIButton.Configuration {
    var configuration = filled()
    configuration.title = title
    return configuration
  }

  static func tinted(title: String) -> UIButton.Configuration {
    var configuration = tinted()
    configuration.title = title
    return configuration
  }

  static func plain(title: String) -> UIButton.Configuration {
    var configuration = plain()
    configuration.title = title
    return configuration
  }
}
