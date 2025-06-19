//
//  UILabel+Extension.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit

extension UILabel {
  convenience init<S: StringProtocol>(_ text: S) {
    self.init(frame: .zero)
    self.text = String(text)
  }
}
