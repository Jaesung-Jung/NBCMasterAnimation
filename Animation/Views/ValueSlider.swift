//
//  ValueSlider.swift
//  Animation
//
//  Created by 정재성 on 6/21/25.
//

import UIKit
import Then
import SnapKit

final class ValueSlider: UIControl {
  private let titleLabel = Label().then {
    $0.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
    $0.isHidden = true
  }

  private let valueLabel = Label().then {
    $0.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
    $0.textAlignment = .right
  }

  private let slider = UISlider()

  @inlinable var title: String? {
    get { titleLabel.text }
    set {
      titleLabel.text = newValue
      titleLabel.isHidden = newValue == nil
    }
  }

  @inlinable var value: Float {
    get { slider.value }
    set {
      slider.value = newValue
      valueLabel.text = formattedValue(newValue)
    }
  }

  var step: Float = 1 {
    didSet {
      slider.value = adjustedValue(for: slider.value, step: step, minimumValue: slider.minimumValue)
      valueLabel.text = formattedValue(slider.value)
    }
  }

  @inlinable var minimumValue: Float {
    get { slider.minimumValue }
    set {
      slider.minimumValue = newValue
      slider.value = adjustedValue(for: slider.value, step: step, minimumValue: newValue)
      valueLabel.text = formattedValue(slider.value)
    }
  }

  @inlinable var maximumValue: Float {
    get { slider.maximumValue }
    set {
      slider.maximumValue = newValue
      valueLabel.text = formattedValue(slider.value)
    }
  }

  var titleWidth: CGFloat = 80 {
    didSet {
      titleLabel.snp.updateConstraints {
        $0.width.equalTo(titleWidth)
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    let contentView = UIStackView(axis: .horizontal) {
      titleLabel
      slider
      valueLabel
    }

    titleLabel.snp.makeConstraints {
      $0.width.equalTo(titleWidth)
    }

    valueLabel.snp.makeConstraints {
      $0.width.equalTo(50)
    }

    addSubview(contentView)
    contentView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    let sliderValueChangedAction = UIAction { [unowned self] _ in
      slider.value = adjustedValue(for: slider.value, step: step, minimumValue: slider.minimumValue)
      valueLabel.text = formattedValue(slider.value)
      sendActions(for: .valueChanged)
    }
    slider.addAction(sliderValueChangedAction, for: .valueChanged)

    valueLabel.text = formattedValue(slider.value)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - ValueSlider (Private)

extension ValueSlider {
  private func adjustedValue(for value: Float, step: Float, minimumValue: Float) -> Float {
    ((value - minimumValue) / step).rounded() * step + minimumValue
  }

  private func formattedValue(_ value: Float) -> String {
    "\(slider.value.formatted(.number.precision(.fractionLength(0...1))))"
  }
}

// MARK: - ValueSlider Preview

#Preview {
  ValueSlider().then {
    $0.title = "Slider"
    $0.step = 1
    $0.minimumValue = 10
    $0.maximumValue = 20
  }
}
