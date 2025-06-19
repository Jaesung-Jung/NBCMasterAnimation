//
//  UISlider+Extension.swift
//  Animation
//
//  Created by 정재성 on 6/19/25.
//

import UIKit

extension UISlider {
  convenience init(action: @escaping (Float) -> Void) {
    self.init(frame: .zero, primaryAction: UIAction {
      guard let slider = $0.sender as? UISlider else {
        return
      }
      action(slider.value)
    })
  }
}
