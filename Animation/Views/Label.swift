//
//  Label.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then

final class Label: UILabel {
  var textInsets: UIEdgeInsets = .zero {
    didSet {
      guard textInsets != oldValue else {
        return
      }
      setNeedsDisplay()
      invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: (size.width + textInsets.left + textInsets.right).rounded(.up),
      height: (size.height + textInsets.top + textInsets.bottom).rounded(.up)
    )
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.adjustsFontForContentSizeCategory = true
    self.maximumContentSizeCategory = .extraExtraExtraLarge
    self.insetsLayoutMarginsFromSafeArea = false
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience init(_ text: String) {
    self.init(frame: .zero)
    self.text = text
  }

  convenience init(localized resource: LocalizedStringResource) {
    self.init(frame: .zero)
    self.text = String(localized: resource)
  }

  override func drawText(in rect: CGRect) {
    super.drawText(in: rect.inset(by: textInsets))
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
    let fittingSize = super.systemLayoutSizeFitting(targetSize)
    return CGSize(
      width: fittingSize.width + textInsets.left + textInsets.right,
      height: fittingSize.height + textInsets.top + textInsets.bottom
    )
  }

  override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    let fittingSize = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    return CGSize(
      width: fittingSize.width + textInsets.left + textInsets.right,
      height: fittingSize.height + textInsets.top + textInsets.bottom
    )
  }
}

// MARK: - DSLabel Preview

#Preview {
  Label("LABEL").then {
    $0.textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
  }
}
